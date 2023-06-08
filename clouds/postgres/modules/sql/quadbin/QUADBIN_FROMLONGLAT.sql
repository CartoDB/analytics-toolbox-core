----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    resolution INTEGER
)
RETURNS BIGINT
AS
$BODY$
    SELECT CASE
    WHEN resolution < 0 OR resolution > 26
    THEN @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid resolution "%s"; should be between 0 and 26', resolution))::BIGINT
    WHEN longitude IS NULL OR latitude IS NULL OR resolution IS NULL
    THEN NULL::BIGINT
    ELSE
        (WITH
        __params AS (
            SELECT
                resolution AS z,
                (1 << resolution) AS __z2,
                GREATEST(-85.05, LEAST(85.05, latitude)) AS latitude
        ),
        ___sinlat AS (
            SELECT
                SIN(latitude * PI() / 180.0) as __sinlat
            FROM __params
        ),
        ___x AS (
            SELECT
                (FLOOR(__z2 * ((longitude / 360.0) + 0.5)))::BIGINT & (__z2 - 1) AS __x
            FROM
                __params
        ),
        __zxy AS (
            SELECT
                z,
                CASE
                    WHEN __x < 0 THEN __x + __z2
                    ELSE __x
                END AS x,
                (FLOOR(__z2 * (0.5 - 0.25 * (LN((1 + __sinlat)/(1 - __sinlat)) / PI()))))::BIGINT AS y
            FROM
                __params,
                ___sinlat,
                ___x
        )
        SELECT @@PG_SCHEMA@@.QUADBIN_FROMZXY(z, x::INT, y::INT)
        FROM __zxy)
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
