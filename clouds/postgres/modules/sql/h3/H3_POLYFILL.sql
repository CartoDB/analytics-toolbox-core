----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL(
    geojson TEXT,
    resolution INTEGER
)
RETURNS VARCHAR(16)[]
AS $$
    if (!geojson || resolution == null) {
        return [];
    }
    if (resolution < 0 || resolution > 15) {
        return [];
    }

    @@PG_LIBRARY_H3@@

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
            return [];
    }

    if (polygonCoordinatesA.length + polygonCoordinatesB.length === 0) {
        return [];
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
$$ LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_POLYFILL(
    geom GEOMETRY,
    resolution INTEGER
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    SELECT @@PG_SCHEMA@@.__H3_POLYFILL(ST_ASGEOJSON(geom), resolution);
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;