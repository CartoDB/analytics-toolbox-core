----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _H3_POLYFILL
(geojson STRING, _resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || _RESOLUTION == null) {
        return [];
    }

    @@SF_LIBRARY_ASH3_POLYFILL@@

    const resolution = Number(_RESOLUTION);
    if (resolution < 0 || resolution > 16) {
        return [];
    }

    const bboxA = [-180, -90, 0, 90]
    const bboxB = [0, -90, 180, 90]
    const featureGeometry = JSON.parse(GEOJSON)
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
$$;

CREATE OR REPLACE SECURE FUNCTION H3_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    _H3_POLYFILL(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;