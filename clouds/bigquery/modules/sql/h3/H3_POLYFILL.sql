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

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYFILL_INIT`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        CAST(NULL AS ARRAY<STRING>),
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
            UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT`(geog, CAST(resolution / 2 AS INT64))) AS parent,
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
            UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT`(geog, CAST(resolution / 2 AS INT64))) AS parent,
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
            UNNEST(`@@BQ_DATASET@@.__H3_POLYFILL_INIT`(geog, CAST(resolution / 2 AS INT64))) AS parent,
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
    SELECT CASE
        -- need check resolution here before calls because _INIT receive resolution-1
        WHEN resolution < 0 OR resolution > 15 THEN CAST(NULL AS ARRAY<STRING>)
        WHEN resolution IS NULL OR geog IS NULL THEN CAST(NULL AS ARRAY<STRING>)
        WHEN mode = 'intersects' THEN `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_INTERSECTS`(geog, resolution)
        WHEN mode = 'contains' THEN `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CONTAINS`(geog, resolution)
        WHEN mode ='center' THEN `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_CENTER`(geog, resolution)
    END
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    SELECT CASE
        -- need check resolution here before calls because _INIT receive resolution-1
        WHEN resolution < 0 OR resolution > 15 THEN CAST(NULL AS ARRAY<STRING>)
        WHEN resolution IS NULL OR geog IS NULL THEN CAST(NULL AS ARRAY<STRING>)
        WHEN ST_DIMENSION(geog) = 0 THEN
             [`@@BQ_DATASET@@.H3_FROMGEOGPOINT`(geog, resolution)]
        ELSE
            `@@BQ_DATASET@@.__H3_POLYFILL_CHILDREN_INTERSECTS`(geog, resolution)
    END
));
