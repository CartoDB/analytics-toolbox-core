----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__H3_POLYFILL`
(geojson STRING, _resolution INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
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
                    var clippedGeometryA = h3Lib.bboxClip(geom, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat(clippedGeometryA.coordinates);
                    var clippedGeometryB = h3Lib.bboxClip(geom, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat(clippedGeometryB.coordinates);
                } else if (geom.type === 'Polygon') {
                    var clippedGeometryA = h3Lib.bboxClip(geom, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat([clippedGeometryA.coordinates]);
                    var clippedGeometryB = h3Lib.bboxClip(geom, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat([clippedGeometryB.coordinates]);
                }
            });
        break;
        case 'MultiPolygon':
            var clippedGeometryA = h3Lib.bboxClip(featureGeometry, bboxA).geometry;
            polygonCoordinatesA = clippedGeometryA.coordinates;
            var clippedGeometryB = h3Lib.bboxClip(featureGeometry, bboxB).geometry;
            polygonCoordinatesB = clippedGeometryB.coordinates;
        break;
        case 'Polygon':
            var clippedGeometryA = h3Lib.bboxClip(featureGeometry, bboxA).geometry;
            polygonCoordinatesA = [clippedGeometryA.coordinates];
            var clippedGeometryB = h3Lib.bboxClip(featureGeometry, bboxB).geometry;
            polygonCoordinatesB = [clippedGeometryB.coordinates];
        break;
        default:
            return null;
    }

    if (polygonCoordinatesA.length + polygonCoordinatesB.length === 0) {
        return null;
    }

    let hexesA = polygonCoordinatesA.reduce(
        (acc, coordinates) => acc.concat(h3Lib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    let hexesB = polygonCoordinatesB.reduce(
        (acc, coordinates) => acc.concat(h3Lib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...hexesA, ...hexesB];
    hexes = [...new Set(hexes)];

    return hexes;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.H3_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS (
    `@@BQ_PREFIX@@carto.__H3_POLYFILL`(ST_ASGEOJSON(geog), resolution)
);