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
    if (!geojson || _resolution == null) {
        return null
    }

    const resolution = Number(_resolution)
    if (resolution < 0 || resolution > 15) {
        return null
    }

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

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_RESOLUTION_BY_AREA`
(area FLOAT64)
RETURNS INT64
AS ((
    SELECT CASE
        WHEN area > 4357449416078.392 THEN 0
        WHEN area > 609788441794.134 THEN 1
        WHEN area > 86801780398.997 THEN 2
        WHEN area > 12393434655.088 THEN 3
        WHEN area > 1770347654.491 THEN 4
        WHEN area > 252903858.182 THEN 5
        WHEN area > 36129062.164 THEN 6
        WHEN area > 5161293.360 THEN 7
        WHEN area > 737327.598 THEN 8
        WHEN area > 105332.513 THEN 9
        WHEN area > 15047.502 THEN 10
        WHEN area > 2149.643 THEN 11
        WHEN area > 307.092 THEN 12
        WHEN area > 43.870 THEN 13
        WHEN area > 6.267 THEN 14
        ELSE 15
    END
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INTERMEDIATE_RESOLUTION`
(geog GEOGRAPHY)
RETURNS INT64
AS ((
    WITH _bbox AS (SELECT ST_BOUNDINGBOX(geog) AS bbox)
        SELECT `@@BQ_DATASET@@.__H3_POLYFILL_RESOLUTION_BY_AREA`(ST_AREA(`@@BQ_DATASET@@.ST_MAKEENVELOPE`(bbox.xmin, bbox.ymin, bbox.xmax, bbox.ymax))) FROM _bbox
));

-- CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INTERMEDIATE_RESOLUTION`
-- (geog GEOGRAPHY)
-- RETURNS INT64
-- AS ((
--     SELECT `@@BQ_DATASET@@.__H3_POLYFILL_RESOLUTION_BY_AREA`(ST_AREA(`@@BQ_DATASET@@.ST_ENVELOPE`([geog])))
-- ));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INIT`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        NULL,
        IF(resolution < 0 OR resolution > 15,
            ERROR('Invalid resolution, should be between 0 and 15'), (
            SELECT `@@BQ_DATASET@@.__H3_POLYFILL_GEOJSON`(
                ST_ASGEOJSON(ST_BUFFER(geog, `@@BQ_DATASET@@.__H3_AVG_EDGE_LENGTH`(resolution))),
                resolution
            )
        ))
    )
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_INTERSECTS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH cells AS (
        SELECT h3
        FROM
            UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT`(geog, GREATEST(CAST(resolution / 2 AS INT64), `@@BQ_DATASET@@.__H3_POLYFILL_INTERMEDIATE_RESOLUTION`(geog)))) AS parent,
            UNNEST(`@@BQ_DATASET@@.H3_TOCHILDREN`(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM cells
    WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.H3_BOUNDARY`(h3))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CONTAINS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH cells AS (
        SELECT h3
        FROM
            UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT`(geog, GREATEST(CAST(resolution / 2 AS INT64), `@@BQ_DATASET@@.__H3_POLYFILL_INTERMEDIATE_RESOLUTION`(geog)))) AS parent,
            UNNEST(`@@BQ_DATASET@@.H3_TOCHILDREN`(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM cells
    WHERE ST_CONTAINS(geog, `@@BQ_DATASET@@.H3_BOUNDARY`(h3))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CENTER`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH cells AS (
        SELECT h3
        FROM
            UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT`(geog, GREATEST(CAST(resolution / 2 AS INT64), `@@BQ_DATASET@@.__H3_POLYFILL_INTERMEDIATE_RESOLUTION`(geog)))) AS parent,
            UNNEST(`@@BQ_DATASET@@.H3_TOCHILDREN`(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM cells
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
    SELECT `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_INTERSECTS`(geog, resolution)
));
