----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_TO_S2_MAPPING
(resolution INT)
RETURNS INT
IMMUTABLE
AS $$
    CASE RESOLUTION
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
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYGONS_POLYFILL
(geojson STRING, input_resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || INPUT_RESOLUTION == null) {
        return [];
    }

    @@SF_LIBRARY_H3_POLYFILL@@

    const resolution = Number(INPUT_RESOLUTION);
    if (resolution < 0 || resolution > 15) {
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
                    var clippedGeometryA = h3PolyfillLib.bboxClip(geom, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat(clippedGeometryA.coordinates);
                    var clippedGeometryB = h3PolyfillLib.bboxClip(geom, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat(clippedGeometryB.coordinates);
                } else if (geom.type === 'Polygon') {
                    var clippedGeometryA = h3PolyfillLib.bboxClip(geom, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat([clippedGeometryA.coordinates]);
                    var clippedGeometryB = h3PolyfillLib.bboxClip(geom, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat([clippedGeometryB.coordinates]);
                }
            });
        break;
        case 'MultiPolygon':
            var clippedGeometryA = h3PolyfillLib.bboxClip(featureGeometry, bboxA).geometry;
            polygonCoordinatesA = clippedGeometryA.coordinates;
            var clippedGeometryB = h3PolyfillLib.bboxClip(featureGeometry, bboxB).geometry;
            polygonCoordinatesB = clippedGeometryB.coordinates;
        break;
        case 'Polygon':
            var clippedGeometryA = h3PolyfillLib.bboxClip(featureGeometry, bboxA).geometry;
            polygonCoordinatesA = [clippedGeometryA.coordinates];
            var clippedGeometryB = h3PolyfillLib.bboxClip(featureGeometry, bboxB).geometry;
            polygonCoordinatesB = [clippedGeometryB.coordinates];
        break;
        default:
            return [];
    }

    if (polygonCoordinatesA.length + polygonCoordinatesB.length === 0) {
        return [];
    }

    let hexesA = polygonCoordinatesA.reduce(
        (acc, coordinates) => acc.concat(h3PolyfillLib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    let hexesB = polygonCoordinatesB.reduce(
        (acc, coordinates) => acc.concat(h3PolyfillLib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...hexesA, ...hexesB];
    hexes = [...new Set(hexes)];

    return hexes;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._H3_LINES_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    WITH t AS (
        SELECT @@SF_SCHEMA@@.H3_FROMGEOGPOINT(ST_CENTROID(@@SF_SCHEMA@@.S2_BOUNDARY(VALUE)), RESOLUTION) h3_cell
        FROM LATERAL FLATTEN(input => @@SF_SCHEMA@@._S2_POLYFILL_BBOX(GEOG, @@SF_SCHEMA@@._H3_TO_S2_MAPPING(RESOLUTION)))
    )
    SELECT ARRAY_AGG(DISTINCT h3_cell)
    FROM t
    WHERE ST_INTERSECTS(@@SF_SCHEMA@@.H3_BOUNDARY(h3_cell), GEOG)
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE
        WHEN ST_DIMENSION(GEOG) = 0 AND @@SF_SCHEMA@@._H3_TO_S2_MAPPING(RESOLUTION) != NULL THEN
            [@@SF_SCHEMA@@.H3_FROMGEOGPOINT(GEOG, RESOLUTION)]
        WHEN ST_DIMENSION(GEOG) = 1 AND @@SF_SCHEMA@@._H3_TO_S2_MAPPING(RESOLUTION) != NULL THEN
            @@SF_SCHEMA@@._H3_LINES_POLYFILL(GEOG, RESOLUTION)
        ELSE
            @@SF_SCHEMA@@._H3_POLYGONS_POLYFILL(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE))
    END
$$;
