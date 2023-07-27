---------------------------------
-- Copyright (C) 2021-2023 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_GEOJSON`
(geojson STRING, _resolution INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_BUCKET@@"]
)
AS """
    const resolution = Number(_resolution)
    const bboxA = [-180, -90, 0, 90]
    const bboxB = [0, -90, 180, 90]
    const featureGeometry = JSON.parse(geojson)
    let polygonCoordinatesA = []
    let polygonCoordinatesB = []
    switch(featureGeometry.type) {
        case 'GeometryCollection':
            featureGeometry.geometries.forEach(function (geom) {
                if (geom.type === 'MultiPolygon') {
                    var clippedGeometryA = lib.h3.bboxClip(geom, bboxA).geometry
                    polygonCoordinatesA = polygonCoordinatesA.concat(clippedGeometryA.coordinates)
                    var clippedGeometryB = lib.h3.bboxClip(geom, bboxB).geometry
                    polygonCoordinatesB = polygonCoordinatesB.concat(clippedGeometryB.coordinates)
                } else if (geom.type === 'Polygon') {
                    var clippedGeometryA = lib.h3.bboxClip(geom, bboxA).geometry
                    polygonCoordinatesA = polygonCoordinatesA.concat([clippedGeometryA.coordinates])
                    var clippedGeometryB = lib.h3.bboxClip(geom, bboxB).geometry
                    polygonCoordinatesB = polygonCoordinatesB.concat([clippedGeometryB.coordinates])
                }
            })
        break
        case 'MultiPolygon':
            var clippedGeometryA = lib.h3.bboxClip(featureGeometry, bboxA).geometry
            polygonCoordinatesA = clippedGeometryA.coordinates
            var clippedGeometryB = lib.h3.bboxClip(featureGeometry, bboxB).geometry
            polygonCoordinatesB = clippedGeometryB.coordinates
        break
        case 'Polygon':
            var clippedGeometryA = lib.h3.bboxClip(featureGeometry, bboxA).geometry
            polygonCoordinatesA = [clippedGeometryA.coordinates]
            var clippedGeometryB = lib.h3.bboxClip(featureGeometry, bboxB).geometry
            polygonCoordinatesB = [clippedGeometryB.coordinates]
        break
        default:
            return null
    }

    if (polygonCoordinatesA.length + polygonCoordinatesB.length === 0) {
        return null
    }

    let hexesA = polygonCoordinatesA.reduce(
        (acc, coordinates) => acc.concat(lib.h3.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null)
    let hexesB = polygonCoordinatesB.reduce(
        (acc, coordinates) => acc.concat(lib.h3.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null)
    hexes = [...hexesA, ...hexesB]
    hexes = [...new Set(hexes)]

    return hexes
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_AVG_EDGE_LENGTH`
(resolution INT64)
RETURNS FLOAT64
DETERMINISTIC
LANGUAGE js
AS """
    // https://h3geo.org/docs/core-library/restable/#edge-lengths
    return {
        0: 1281256.011,
        1: 483056.8391,
        2: 182512.9565,
        3: 68979.22179,
        4: 26071.75968,
        5: 9854.090990,
        6: 3724.532667,
        7: 1406.475763,
        8: 531.414010,
        9: 200.786148,
        10: 75.863783,
        11: 28.663897,
        12: 10.830188,
        13: 4.092010,
        14: 1.546100,
        15: 0.584169
    }[resolution]
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_AVG_HEXAGON_AREA`
(resolution INT64)
RETURNS FLOAT64
DETERMINISTIC
LANGUAGE js
AS """
    // https://h3geo.org/docs/core-library/restable/#average-area-in-m2
    return {
        0: 4357449416078.392,
        1: 609788441794.134,
        2: 86801780398.997,
        3: 12393434655.088,
        4: 1770347654.491,
        5: 252903858.182,
        6: 36129062.164,
        7: 5161293.360,
        8: 737327.598,
        9: 105332.513,
        10: 15047.502,
        11: 2149.643,
        12: 307.092,
        13: 43.870,
        14: 6.267,
        15: 0.895
    }[resolution]
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INIT_BBOX`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        NULL,
        IF(resolution < 0 OR resolution > 15,
            ERROR('Invalid resolution, should be between 0 and 15'), (
            WITH __bbox AS (
                SELECT ST_BOUNDINGBOX(geog) AS box
            ),
            __params AS (
                SELECT
                    IF(ST_DIMENSION(geog) = 0,
                        geog,
                        `@@BQ_DATASET@@.ST_MAKEENVELOPE`(box.xmin, box.ymin, box.xmax, box.ymax)
                    ) AS bbox,
                    `@@BQ_DATASET@@.__H3_AVG_EDGE_LENGTH`(resolution) AS edge_length
                FROM __bbox
            ),
            __cells AS (
                SELECT parent
                FROM __params, UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_GEOJSON`(
                    ST_ASGEOJSON(ST_BUFFER(bbox, edge_length)),
                    resolution
                )) AS parent
                WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.H3_BOUNDARY`(parent))
            )
            SELECT ARRAY_AGG(parent)
            FROM __cells
        ))
    )
));

-- alternative to __H3_POLYFILL_INIT_BBOX
CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INIT_SIMP`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        NULL,
        IF(resolution < 0 OR resolution > 15,
            ERROR('Invalid resolution, should be between 0 and 15'), (
            WITH __params AS (
                SELECT `@@BQ_DATASET@@.__H3_AVG_EDGE_LENGTH`(resolution) AS edge_length
            )
            SELECT `@@BQ_DATASET@@.__H3_POLYFILL_GEOJSON`(
                ST_ASGEOJSON(ST_BUFFER(ST_SIMPLIFY(geog, edge_length / 10), edge_length)),
                resolution
            )
            FROM __params
        ))
    )
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INIT_Z`
(geog GEOGRAPHY, resolution INT64)
RETURNS INT64
AS ((
    WITH __params AS (
        SELECT ST_AREA(geog) AS geog_area,
            `@@BQ_DATASET@@.__H3_AVG_HEXAGON_AREA`(resolution) AS cell_area
    )
    -- return the min value between the target and intermediate resolutions
    SELECT LEAST(
        resolution,
        -- compute the resolution of cells that match the geog area
        -- by comparing with the area of the cell, plus 3 levels
        IF(geog_area > 0, resolution - CAST(LOG(geog_area / cell_area, 7) AS INT64) + 3, resolution))
    FROM __params
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_INTERSECTS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH __cells AS (
        SELECT h3
        FROM UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT_BBOX`(geog,
                `@@BQ_DATASET@@.__H3_POLYFILL_INIT_Z`(geog, resolution))) AS parent,
            UNNEST(`@@BQ_DATASET@@.H3_TOCHILDREN`(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM __cells
    WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.H3_BOUNDARY`(h3))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CONTAINS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH __cells AS (
        SELECT h3
        FROM UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT_BBOX`(geog,
                `@@BQ_DATASET@@.__H3_POLYFILL_INIT_Z`(geog, resolution))) AS parent,
            UNNEST(`@@BQ_DATASET@@.H3_TOCHILDREN`(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM __cells
    WHERE ST_CONTAINS(geog, `@@BQ_DATASET@@.H3_BOUNDARY`(h3))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CENTER`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH __cells AS (
        SELECT h3
        FROM UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT_BBOX`(geog,
                `@@BQ_DATASET@@.__H3_POLYFILL_INIT_Z`(geog, resolution))) AS parent,
            UNNEST(`@@BQ_DATASET@@.H3_TOCHILDREN`(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM __cells
    WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.H3_CENTER`(h3))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_POLYFILL_MODE`
(geog GEOGRAPHY, resolution INT64, mode STRING)
RETURNS ARRAY<STRING>
AS ((
    CASE mode
        WHEN 'intersects' THEN `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_INTERSECTS`(geog, resolution)
        WHEN 'contains' THEN `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CONTAINS`(geog, resolution)
        WHEN 'center' THEN `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CENTER`(geog, resolution)
    END
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CENTER`(geog, resolution)
));
