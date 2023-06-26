--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(
    geog GEOGRAPHY,
    resolution NUMBER
)
RETURNS BIGINT[]
AS $BODY$
  SELECT CASE
    WHEN resolution < 0 OR resolution > 26
        THEN @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid resolution "%s"; should be between 0 and 26', resolution))::BIGINT[]
    WHEN resolution IS NULL OR geom IS NULL
        THEN NULL::BIGINT[]
    ELSE (
        WITH
        __params AS (
            SELECT
                resolution AS z,
                ST_XMIN(geog::geometry) AS minlon,
                ST_YMIN(geog::geometry) AS minlat,
                ST_XMAX(geog::geometry) AS maxlon,
                ST_YMAX(geog::geometry) AS maxlat,
                (1::BIGINT << resolution) AS z2,
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
                (FLOOR(z2 * ((minlon / 360.0) + 0.5))::BIGINT &  (z2 - 1) -- bitwise way to calc MODULO
                ) AS xmin,
                (FLOOR(z2 * ((maxlon / 360.0) + 0.5))::BIGINT & (z2 - 1) -- bitwise way to calc MODULO
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

                -- floor before cast to avoid up rounding to the next tile
                FLOOR(
                    z2 * (
                        0.5 - 0.25 * LN(
                            (1 + sinlat_max) / (1 - sinlat_max)
                        ) / pi
                    )
                )::BIGINT AS ymin,

                CASE
                    WHEN xmax < 0 THEN xmax + z2
                    ELSE xmax
                END
                AS xmax,

                -- floor before cast to avoid up rounding to the next tiLe
                FLOOR(
                    z2 * (
                        0.5 - 0.25 * LN(
                            (1 + sinlat_min) / (1 - sinlat_min)
                        ) / pi
                    )
                )::BIGINT AS ymax

            FROM __params, __xs, __sinlat
        ),
        __cells AS (
            SELECT @@PG_SCHEMA@@.QUADBIN_FROMZXY(z::INT, x::INT, y::INT) AS quadbin
            FROM __tile_coords_range as t,
                generate_series(t.xmin, t.xmax) AS x,
                generate_series(t.ymin, t.ymax) AS y
        )
        SELECT count(__cells), ARRAY_AGG(quadbin)
        FROM __cells, __values
        WHERE ST_INTERSECTS(@@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin), geog)
    )
    END;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;


CREATE OR REPLACE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(
    geog GEOGRAPHY,
    resolution INT
)
RETURNS BIGINT[]
AS $BODY$
    WITH cells AS (
        SELECT quadbin
        FROM
            UNNEST(@@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(geog, (resolution / 2)::INT)) AS parent,
            UNNEST(@@SF_DATASET@@.QUADBIN_TOCHILDREN(parent, resolution))) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM cells
    WHERE ST_INTERSECTS(geog, @@SF_DATASET@@.QUADBIN_BOUNDARY(quadbin));
$BODY$;

-- CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS
-- (geog GEOGRAPHY, resolution NUMBER)
-- RETURNS ARRAY
-- AS ((
--     WITH cells AS (
--         SELECT quadbin
--         FROM
--             UNNEST(@@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(geog, CAST(resolution / 2 AS NUMBER))) AS parent,
--             UNNEST(@@SF_DATASET@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
--     )
--     SELECT ARRAY_AGG(quadbin)
--     FROM cells
--     WHERE ST_CONTAINS(geog, @@SF_DATASET@@.QUADBIN_BOUNDARY(quadbin))
-- ));

-- CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER
-- (geog GEOGRAPHY, resolution NUMBER)
-- RETURNS ARRAY
-- AS ((
--     WITH cells AS (
--         SELECT quadbin
--         FROM
--             UNNEST(@@SF_DATASET@@.__QUADBIN_POLYFILL_INIT(geog, CAST(resolution / 2 AS NUMBER))) AS parent,
--             UNNEST(@@SF_DATASET@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
--     )
--     SELECT ARRAY_AGG(quadbin)
--     FROM cells
--     WHERE ST_INTERSECTS(geog, @@SF_DATASET@@.QUADBIN_CENTER(quadbin))
-- ));

-- CREATE OR REPLACE SECURE FUNCTION @@SF_DATASET@@.QUADBIN_POLYFILL_MODE
-- (geog GEOGRAPHY, resolution NUMBER, mode STRING)
-- RETURNS ARRAY
-- AS ((
--     CASE mode
--         WHEN 'intersects' THEN @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geog, resolution)
--         WHEN 'contains' THEN @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(geog, resolution)
--         WHEN 'center' THEN @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(geog, resolution)
--     END
-- ));

CREATE OR REPLACE FUNCTION @@SF_DATASET@@.QUADBIN_POLYFILL(
    geog GEOGRAPHY,
    resolution INT
)
RETURNS BIGINT[]
AS $BODY$
    SELECT @@SF_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geog, resolution);
$BODY$;

