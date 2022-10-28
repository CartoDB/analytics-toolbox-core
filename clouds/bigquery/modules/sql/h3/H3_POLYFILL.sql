----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_TO_S2_MAPPING`
(resolution INT64)
RETURNS INT64
AS ((
    CASE resolution
    WHEN 0 THEN 4
    WHEN 1 THEN 6
    WHEN 2 THEN 7
    WHEN 3 THEN 8
    WHEN 4 THEN 10
    WHEN 5 THEN 11
    WHEN 6 THEN 13
    WHEN 7 THEN 14
    WHEN 8 THEN 15
    WHEN 9 THEN 16
    WHEN 10 THEN 17
    WHEN 11 THEN 18
    WHEN 12 THEN 20
    WHEN 13 THEN 22
    WHEN 14 THEN 23
    WHEN 15 THEN 24
    ELSE
        NULL
    END
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_POLYGONS_POLYFILL`
(geojson STRING, _resolution INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_BUCKET@@"]
)
AS """
    if (!geojson || _resolution == null) {
        return null;
    }

    const resolution = Number(_resolution);
    if (resolution < 0 || resolution > 15) {
        return null;
    }

    const bboxA = [-180, -90, 0, 90]
    const bboxB = [0, -90, 180, 90]
    const featureGeometry = JSON.parse(geojson)
    let polygonCoordinatesA = [];
    let polygonCoordinatesB = [];
    switch(featureGeometry.type) {
        case 'GeometryCollection':
            featureGeometry.geometries.forEach(function (geom) {
                if (geom.type === 'MultiPolygon') {
                    var clippedGeometryA = lib.h3.bboxClip(geom, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat(clippedGeometryA.coordinates);
                    var clippedGeometryB = lib.h3.bboxClip(geom, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat(clippedGeometryB.coordinates);
                } else if (geom.type === 'Polygon') {
                    var clippedGeometryA = lib.h3.bboxClip(geom, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat([clippedGeometryA.coordinates]);
                    var clippedGeometryB = lib.h3.bboxClip(geom, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat([clippedGeometryB.coordinates]);
                }
            });
        break;
        case 'MultiPolygon':
            var clippedGeometryA = lib.h3.bboxClip(featureGeometry, bboxA).geometry;
            polygonCoordinatesA = clippedGeometryA.coordinates;
            var clippedGeometryB = lib.h3.bboxClip(featureGeometry, bboxB).geometry;
            polygonCoordinatesB = clippedGeometryB.coordinates;
        break;
        case 'Polygon':
            var clippedGeometryA = lib.h3.bboxClip(featureGeometry, bboxA).geometry;
            polygonCoordinatesA = [clippedGeometryA.coordinates];
            var clippedGeometryB = lib.h3.bboxClip(featureGeometry, bboxB).geometry;
            polygonCoordinatesB = [clippedGeometryB.coordinates];
        break;
        default:
            return null;
    }

    if (polygonCoordinatesA.length + polygonCoordinatesB.length === 0) {
        return null;
    }

    let hexesA = polygonCoordinatesA.reduce(
        (acc, coordinates) => acc.concat(lib.h3.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    let hexesB = polygonCoordinatesB.reduce(
        (acc, coordinates) => acc.concat(lib.h3.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...hexesA, ...hexesB];
    hexes = [...new Set(hexes)];

    return hexes;
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_LINES_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
    WITH t AS (
        SELECT `@@BQ_DATASET@@.H3_FROMGEOGPOINT`(ST_CENTROID(`@@BQ_DATASET@@.S2_BOUNDARY`(s2_index)), resolution) AS h3_cell
        FROM UNNEST(S2_COVERINGCELLIDS(geog, max_level => `@@BQ_DATASET@@.__H3_TO_S2_MAPPING`(resolution), min_level => 0, max_cells => 1000000)) AS s2_parent,
            UNNEST(`@@BQ_DATASET@@.__S2_TOCHILDREN`(s2_parent, `@@BQ_DATASET@@.__H3_TO_S2_MAPPING`(resolution))) AS s2_index
    )
    SELECT ARRAY_AGG(DISTINCT h3_cell)
    FROM t
    WHERE ST_INTERSECTS(`@@BQ_DATASET@@.H3_BOUNDARY`(h3_cell), geog)
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS (
    CASE ST_DIMENSION(geog)
    WHEN 0 THEN
        [`@@BQ_DATASET@@.H3_FROMGEOGPOINT`(geog, resolution)]
    WHEN 1 THEN
        IF(`@@BQ_DATASET@@.__H3_TO_S2_MAPPING`(resolution) IS NULL,
               `@@BQ_DATASET@@.__H3_POLYGONS_POLYFILL`(
           ST_ASGEOJSON(geog), resolution
            ),
            `@@BQ_DATASET@@.__H3_LINES_POLYFILL`(
            geog, resolution)
        )
    ELSE
       `@@BQ_DATASET@@.__H3_POLYGONS_POLYFILL`(
           ST_ASGEOJSON(geog), resolution
       )
    END
);
