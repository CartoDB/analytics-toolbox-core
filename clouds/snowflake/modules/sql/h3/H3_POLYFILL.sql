----------------------------
-- Copyright (C) 2021 CARTO
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
            featureGeometry.geometries.forEach(function (geog) {
                if (geog.type === 'MultiPolygon') {
                    var clippedGeometryA = h3PolyfillLib.bboxClip(geog, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat(clippedGeometryA.coordinates);
                    var clippedGeometryB = h3PolyfillLib.bboxClip(geog, bboxB).geometry;
                    polygonCoordinatesB = polygonCoordinatesB.concat(clippedGeometryB.coordinates);
                } else if (geog.type === 'Polygon') {
                    var clippedGeometryA = h3PolyfillLib.bboxClip(geog, bboxA).geometry;
                    polygonCoordinatesA = polygonCoordinatesA.concat([clippedGeometryA.coordinates]);
                    var clippedGeometryB = h3PolyfillLib.bboxClip(geog, bboxB).geometry;
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

// CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL
// (geog GEOGRAPHY, resolution INT)
// RETURNS ARRAY
// IMMUTABLE
// AS $$
//     @@SF_SCHEMA@@._H3_POLYFILL(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE))
// $$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_AVG_EDGE_LENGTH
(resolution INTEGER)
RETURNS DOUBLE
IMMUTABLE
AS $$
    SELECT CASE resolution
    WHEN 0 THEN 1281256.011
    WHEN 1 THEN 483056.8391
    WHEN 2 THEN 182512.9565
    WHEN 3 THEN 68979.22179
    WHEN 4 THEN 26071.75968
    WHEN 5 THEN 9854.090990
    WHEN 6 THEN 3724.532667
    WHEN 7 THEN 1406.475763
    WHEN 8 THEN 531.414010
    WHEN 9 THEN 200.786148
    WHEN 10 THEN 75.863783
    WHEN 11 THEN 28.663897
    WHEN 12 THEN 10.830188
    WHEN 13 THEN 4.092010
    WHEN 14 THEN 1.546100
    WHEN 15 THEN 0.584169
    ELSE
        NULL
    END
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_INIT
(geog GEOGRAPHY, resolution INTEGER)
RETURNS ARRAY
IMMUTABLE
AS $$
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
                CASE
                WHEN resolution < 0 OR resolution > 15 THEN NULL
                WHEN resolution IS NULL OR geog IS NULL THEN NULL
                ELSE
                    @@SF_SCHEMA@@._H3_POLYFILL_GEOJSON(
                        ST_ASGEOJSON(
                            ST_BUFFER(
                                geog,
                                @@SF_SCHEMA@@._H3_AVG_EDGE_LENGTH(resolution)
                            )
                        ),
                        resolution
                    )
                END
            )
        ))
    )
$$;

-- Utility function to optimize polyfill unzooming and getting childrens
-- of unzoomed parents. Thios would allow server side SQL parallelization
-- NOTE! no intersection is done due to generation of internale error =>
-- cleaning of H3s have to be done extenally
CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_CHILDRENS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            WITH
                _init AS (
                    SELECT
                        TO_ARRAY(
                            PARSE_JSON(
                                -- Uncomment this line to use ther JS version
                                -- of the POLYFILL init
                                -- @@SF_SCHEMA@@._H3_POLYFILL_JSINIT(
                                @@SF_SCHEMA@@._H3_POLYFILL_INIT(
                                    CAST(ST_ASGEOJSON(GEOG) AS STRING),
                                    GREATEST(0, CAST(RESOLUTION-2 AS DOUBLE))
                                )
                            )
                        ) AS H3s_array
                ),
                _parents AS (
                    SELECT
                        cast(res.value as bigint) AS parent_H3
                    FROM
                        _init,
                        lateral FLATTEN(H3s_array) as res
                ),
                _childrens AS (
                    SELECT
                        @@SF_SCHEMA@@.H3_TOCHILDREN(parent_H3, resolution) as child
                    FROM _parents
                )
                SELECT ARRAY_UNION_AGG(child)
                FROM _childrens
            )
        ))
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_INTERSECTS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            WITH
                _childrens_array AS (
                    SELECT
                        @@SF_SCHEMA@@._H3_POLYFILL_CHILDRENS(geog, resolution) as child
                ),
                _childrens AS (
                    SELECT
                        res.value AS child
                    FROM
                        _childrens_array,
                        LATERAL FLATTEN(child) AS res
                )
                SELECT ARRAY_UNION_AGG(child)
                FROM _childrens
                WHERE ST_INTERSECTS(geog, @@SF_SCHEMA@@.H3_BOUNDARY(child))
            )
        ))
     )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL_MODE
(geog GEOGRAPHY, resolution INT, mode STRING)
RETURNS ARRAY
IMMUTABLE
AS $$
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            SELECT
                CASE mode
                    WHEN 'intersects' THEN @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_INTERSECTS(geog, resolution)
                    WHEN 'contains' THEN @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_CONTAINS(geog, resolution)
                    WHEN 'center' THEN @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_CENTER(geog, resolution)
                END
            )
        ))
    )
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
            NULL, (
            IFF(resolution < 0 OR resolution > 15,
                NULL,(
                SELECT
                    @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_INTERSECTS(geog, resolution)
                )
            ))
        )
$$;
