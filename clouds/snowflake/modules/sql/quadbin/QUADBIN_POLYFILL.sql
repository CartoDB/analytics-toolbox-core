--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_INIT
(geog GEOGRAPHY, resolution NUMBER)
RETURNS ARRAY
AS $$
    IFF(geog IS NULL OR resolution IS NULL,
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL, (
            WITH
            __params AS (
                SELECT
                    resolution AS z,
                    ST_XMIN(geog) AS minlon,
                    ST_YMIN(geog) AS minlat,
                    ST_XMAX(geog) AS maxlon,
                    ST_YMAX(geog) AS maxlat,
                    BITSHIFTLEFT(1::NUMBER, resolution) AS z2,
                    ACOS(-1) AS pi
            ),
            __sinlat AS (
                SELECT
                    SIN(minlat * pi / 180.0) AS sinlat_min,
                    SIN(maxlat * pi / 180.0) AS sinlat_max
                FROM __params
            ),
            __xs AS (
                -- precalculate Xs to allow simple use of
                -- CASE in the next CTE
                SELECT
                    BITAND(
                        CAST(
                            FLOOR(z2 * ((minlon / 360.0) + 0.5)) AS NUMBER
                        ),
                        (z2 - 1)   -- bitwise way to calc MODULO
                    ) AS xmin,
                    BITAND(
                        CAST(
                            FLOOR(z2 * ((maxlon / 360.0) + 0.5)) AS NUMBER
                        ),
                        (z2 - 1)   -- bitwise way to calc MODULO
                    ) AS xmax
                FROM __params
            ),
            __tile_coords_range AS (
                SELECT
                    z,

                    CASE
                        WHEN xmin < 0 THEN xmin + z2
                        ELSE xmin
                    END
                    AS xmin,

                    CAST(
                        -- floor before cast to avoid up rounding to the next tile
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_max) / (1 - sinlat_max)
                                ) / pi
                            )
                        ) AS NUMBER
                    )
                    AS ymin,

                    CASE
                        WHEN xmax < 0 THEN xmax + z2
                        ELSE xmax
                    END
                    AS xmax,

                    CAST(
                        -- floor before cast to avoid up rounding to the next tiLe
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_min) / (1 - sinlat_min)
                                ) / pi
                            )
                        ) AS NUMBER
                    )
                    AS ymax

                FROM __params, __xs, __sinlat
            ),
            __cells AS (
                SELECT @@SF_DATASET@@.QUADBIN_FROMZXY(z, x.value, y.value) AS quadbin
                FROM __tile_coords_range,
                    lateral FLATTEN(ARRAY_GENERATE_RANGE(xmin, xmax)) AS x,
                    lateral FLATTEN(ARRAY_GENERATE_RANGE(ymin, ymax)) AS y
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(@@SF_DATASET@@.QUADBIN_BOUNDARY(quadbin), geog
            ))
        ))
    );
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    WITH cells AS (
        SELECT quadbin
        FROM
            TABLE(FLATTEN(@@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(geog, CAST(resolution / 2 AS NUMBER)))) AS parent,
            TABLE(FLATTEN(@@SF_DATASET@@.QUADBIN_TOCHILDREN(parent, resolution))) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM cells
    WHERE ST_INTERSECTS(geog, @@SF_DATASET@@.QUADBIN_BOUNDARY(quadbin));
$$;

// CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS
// (geog GEOGRAPHY, resolution NUMBER)
// RETURNS ARRAY
// AS ((
//     WITH cells AS (
//         SELECT quadbin
//         FROM
//             UNNEST(@@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(geog, CAST(resolution / 2 AS NUMBER))) AS parent,
//             UNNEST(@@SF_DATASET@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
//     )
//     SELECT ARRAY_AGG(quadbin)
//     FROM cells
//     WHERE ST_CONTAINS(geog, @@SF_DATASET@@.QUADBIN_BOUNDARY(quadbin))
// ));

// CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER
// (geog GEOGRAPHY, resolution NUMBER)
// RETURNS ARRAY
// AS ((
//     WITH cells AS (
//         SELECT quadbin
//         FROM
//             UNNEST(@@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(geog, CAST(resolution / 2 AS NUMBER))) AS parent,
//             UNNEST(@@SF_DATASET@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
//     )
//     SELECT ARRAY_AGG(quadbin)
//     FROM cells
//     WHERE ST_INTERSECTS(geog, @@SF_DATASET@@.QUADBIN_CENTER(quadbin))
// ));

// CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.QUADBIN_POLYFILL_MODE
// (geog GEOGRAPHY, resolution NUMBER, mode STRING)
// RETURNS ARRAY
// AS ((
//     CASE mode
//         WHEN 'intersects' THEN @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geog, resolution)
//         WHEN 'contains' THEN @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(geog, resolution)
//         WHEN 'center' THEN @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(geog, resolution)
//     END
// ));

CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.QUADBIN_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    SELECT @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geog, resolution);
$$;
-- CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_POLYFILL
-- (geo GEOGRAPHY, resolution INT)
-- RETURNS ARRAY
-- IMMUTABLE
-- AS $$
--     TO_ARRAY(PARSE_JSON(@@SF_SCHEMA@@._QUADBIN_POLYFILL(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))))
-- $$;

