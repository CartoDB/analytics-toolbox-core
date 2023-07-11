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
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 15,
            NULL,(
                SELECT
                @@SF_SCHEMA@@._H3_POLYFILL_GEOJSON(
                    CAST(
                        ST_ASGEOJSON(
                            ST_BUFFER(
                                TO_GEOMETRY(ST_ASGEOJSON(geog)),
                                @@SF_SCHEMA@@._H3_AVG_EDGE_LENGTH(resolution)
                            )
                    ) AS STRING),
                    CAST(resolution AS DOUBLE)
                )
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
        IFF(resolution < 0 OR resolution > 15,
            NULL,(
            WITH
                _init AS (
                    SELECT
                        -- Uncomment this line to use ther JS version
                        -- of the POLYFILL init
                        -- @@SF_SCHEMA@@._H3_POLYFILL_JSINIT(
                        @@SF_SCHEMA@@._H3_POLYFILL_INIT(
                            GEOG,
                            GREATEST(0, CAST(RESOLUTION-2 AS DOUBLE))
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
        IFF(resolution < 0 OR resolution > 15,
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

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_CONTAINS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 15,
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
                WHERE ST_CONTAINS(geog, @@SF_SCHEMA@@.H3_BOUNDARY(child))
            )
        ))
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_CHILDREN_CENTER
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 15,
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
                WHERE ST_INTERSECTS(geog, @@SF_SCHEMA@@.H3_CENTER(child))
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
        IFF(resolution < 0 OR resolution > 15,
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
