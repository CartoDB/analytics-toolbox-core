----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_GEOJSON
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

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_AVG_EDGE_LENGTH
(resolution INTEGER)
RETURNS DOUBLE
IMMUTABLE
AS $$
    SELECT CASE resolution
    WHEN 0 THEN  CAST(1281256.011 AS DOUBLE)
    WHEN 1 THEN  CAST(483056.8391 AS DOUBLE)
    WHEN 2 THEN  CAST(182512.9565 AS DOUBLE)
    WHEN 3 THEN  CAST(68979.22179 AS DOUBLE)
    WHEN 4 THEN  CAST(26071.75968 AS DOUBLE)
    WHEN 5 THEN  CAST(9854.090990 AS DOUBLE)
    WHEN 6 THEN  CAST(3724.532667 AS DOUBLE)
    WHEN 7 THEN  CAST(1406.475763 AS DOUBLE)
    WHEN 8 THEN  CAST(531.414010 AS DOUBLE)
    WHEN 9 THEN  CAST(200.786148 AS DOUBLE)
    WHEN 10 THEN CAST(75.863783 AS DOUBLE)
    WHEN 11 THEN CAST(28.663897 AS DOUBLE)
    WHEN 12 THEN CAST(10.830188 AS DOUBLE)
    WHEN 13 THEN CAST(4.092010 AS DOUBLE)
    WHEN 14 THEN CAST(1.546100 AS DOUBLE)
    WHEN 15 THEN CAST(0.584169 AS DOUBLE)
    ELSE
        NULL
    END
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_INIT
(geog GEOGRAPHY, resolution INTEGER)
RETURNS ARRAY
IMMUTABLE
AS $$
    SELECT @@SF_SCHEMA@@._H3_POLYFILL_GEOJSON(
        CAST(
            ST_ASGEOJSON(
                @@SF_SCHEMA@@.ST_BUFFER(
                    geog,
                    @@SF_SCHEMA@@._H3_AVG_EDGE_LENGTH(resolution)
                )
        ) AS STRING),
        CAST(resolution AS DOUBLE)
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_QUERY
(
    input_query STRING,
    resolution DOUBLE,
    mode STRING,
    output_table STRING
)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!['center', 'intersects', 'contains'].includes(MODE)) {
        throw Error('Invalid mode, should be center, intersects, or contains.');
    }

    if (RESOLUTION < 0 || RESOLUTION > 15) {
        throw Error('Invalid resolution, should be between 0 and 15.');
    }

    const containmentFunction = (MODE === 'contains') ? 'ST_CONTAINS' : 'ST_INTERSECTS';
    const cellFunction = (MODE === 'center') ? '@@SF_SCHEMA@@.H3_CENTER' : '@@SF_SCHEMA@@.H3_BOUNDARY';

    const parentResolution = Math.max(0, RESOLUTION - 4)

    return `
        CREATE OR REPLACE TABLE ${OUTPUT_TABLE} CLUSTER BY (h3) AS
        WITH __input AS (${INPUT_QUERY}),
        __cells AS (
            SELECT CAST(children.value AS STRING) AS h3, i.*
            FROM __input AS i,
                TABLE(FLATTEN(@@SF_SCHEMA@@._H3_POLYFILL_INIT(geom, ${parentResolution}))) AS parent,
                TABLE(FLATTEN(@@SF_SCHEMA@@.H3_TOCHILDREN(CAST(parent.value AS STRING), ${RESOLUTION}))) AS children
        )
        SELECT * EXCLUDE(geom)
        FROM __cells
        WHERE ${containmentFunction}(geom, ${cellFunction}(h3))
    `;
$$;

CREATE OR REPLACE PROCEDURE @@SF_SCHEMA@@.H3_POLYFILL_TABLE
(
    input_query STRING,
    resolution INT,
    mode STRING,
    output_table STRING
)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS $$
    DECLARE polyfill_query STRING;
    BEGIN
        polyfill_query := (SELECT @@SF_SCHEMA@@._H3_POLYFILL_QUERY(
            :input_query,
            CAST(:resolution AS DOUBLE),
            :mode,
            :output_table
        ));
        EXECUTE IMMEDIATE polyfill_query;
        RETURN 'Polyfill completed.';
    END;
$$;
