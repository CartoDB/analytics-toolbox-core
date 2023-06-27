--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
  SELECT CASE
    WHEN resolution < 0 OR resolution > 26 THEN @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid resolution "%s"; should be between 0 and 26', resolution))::BIGINT[]
    WHEN resolution IS NULL OR geom IS NULL THEN NULL::BIGINT[]
    ELSE (
        WITH
        __geom4326 AS (
            select
                (CASE ST_SRID(geom)
                    WHEN 0 THEN ST_SETSRID(geom, 4326)
                    ELSE ST_TRANSFORM(geom, 4326)
                END) AS geom4326
        ),
        __bbox AS (
            SELECT geom4326, BOX2D(geom4326) AS b FROM __geom4326
        ),
        __params AS (
            SELECT
                geom4326,
                resolution AS z,
                (1::BIGINT << resolution) AS z2,
                ST_XMIN(b) AS minlon,
                ST_YMIN(b) AS minlat,
                ST_XMAX(b) AS maxlon,
                ST_YMAX(b) AS maxlat
            FROM __bbox
        ),
        __sinlat AS (
            SELECT
                SIN(minlat * PI() / 180.0) AS sinlat_min,
                SIN(maxlat * PI() / 180.0) AS sinlat_max
            FROM __params
        ),
        __xs AS (
            -- precalculate Xs to allow simple use of
            -- CASE in the next CTE
            SELECT
                (FLOOR(z2 * ((minlon / 360.0) + 0.5))::BIGINT & (z2 - 1) -- bitwise way to calc MODULO
                ) AS xmin,
                (FLOOR(z2 * ((maxlon / 360.0) + 0.5))::BIGINT & (z2 - 1) -- bitwise way to calc MODULO
                ) AS xmax
            FROM __params
        ),
        __tile_coords_range AS (
            SELECT
                geom4326,
                z,

                (CASE
                    WHEN xmin < 0 THEN xmin + z2
                    ELSE xmin
                END)::INT AS xmin,

                -- floor before cast to avoid up rounding to the next tile
                FLOOR(
                    z2 * (
                        0.5 - 0.25 * LN(
                            (1 + sinlat_max) / (1 - sinlat_max)
                        ) / PI()
                    )
                )::INT AS ymin,

                (CASE
                    WHEN xmax < 0 THEN xmax + z2
                    ELSE xmax
                END)::INT AS xmax,

                -- floor before cast to avoid up rounding to the next tiLe
                FLOOR(
                    z2 * (
                        0.5 - 0.25 * LN(
                            (1 + sinlat_min) / (1 - sinlat_min)
                        ) / PI()
                    )
                )::INT AS ymax

            FROM __params, __xs, __sinlat
        ),
        __cells AS (
            SELECT
                geom4326,
                @@PG_SCHEMA@@.QUADBIN_FROMZXY(z::INT, x::INT, y::INT) AS quadbin
            FROM __tile_coords_range,
                 generate_series(xmin, xmax) AS x,
                 generate_series(ymin, ymax) AS y
        )
        SELECT ARRAY_AGG(quadbin)
        FROM __cells
        WHERE ST_INTERSECTS(geom4326, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin))
    )
    END;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;


CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH
    __geom4326 AS (
        select
            (CASE ST_SRID(geom)
                WHEN 0 THEN ST_SETSRID(geom, 4326)
                ELSE ST_TRANSFORM(geom, 4326)
            END) AS geom4326
    ),
    __cells AS (
        SELECT
            geom4326,
            quadbin
        FROM __geom4326,
             UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom4326, (resolution / 2)::INT)) AS parent,
             UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_INTERSECTS(geom4326, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin));
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS
(geom GEOMETRY, resolution INT)
RETURNS BIGINT[]
AS
$BODY$
    WITH
    __geom4326 AS (
        SELECT
            CASE ST_SRID(geom)
                WHEN 0 THEN ST_SETSRID(geom, 4326)
                ELSE ST_TRANSFORM(geom, 4326)
            END AS geom4326
    ),
    __cells AS (
        SELECT
            geom4326,
            quadbin
        FROM __geom4326,
             UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom4326, (resolution / 2)::INT)) AS parent,
             UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_CONTAINS(geom4326, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER
(geom GEOMETRY, resolution INT)
RETURNS BIGINT[]
AS
$BODY$
    WITH
    __geom4326 AS (
        SELECT
            (CASE ST_SRID(geom)
                WHEN 0 THEN ST_SETSRID(geom, 4326)
                ELSE ST_TRANSFORM(geom, 4326)
            END) AS geom4326
    ),
    __cells AS (
        SELECT
            geom4326,
            quadbin
        FROM __geom4326,
             UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom4326, (resolution / 2)::INT)) AS parent,
             UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_INTERSECTS(geom4326, @@PG_SCHEMA@@.QUADBIN_CENTER(quadbin))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL_MODE
(geom GEOMETRY, resolution INT, mode VARCHAR)
RETURNS BIGINT[]
AS
$BODY$
    SELECT CASE mode
        WHEN 'intersects' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geom, resolution)
        WHEN 'contains' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(geom, resolution)
        WHEN 'center' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(geom, resolution)
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geom, resolution);
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

