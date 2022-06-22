----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_TOZXY`
(quadbin INT64)
RETURNS STRUCT<z INT64, x INT64, y INT64>
AS ((
    WITH
    __interleaved AS (
        SELECT
            (quadbin >> 59) & 7 AS mode,
            (quadbin >> 57) & 3 AS mode_dep,
            (quadbin >> 52) & 0x1F AS z,
            (quadbin & 0xFFFFFFFFFFFFF) << 12 AS q
    ),
    __deinterleaved1 AS (
        SELECT z, q AS x, q >> 1 AS y FROM __interleaved
    ),
    __deinterleaved2 AS (
        SELECT
            z,
            x & 0x5555555555555555 AS x,
            y & 0x5555555555555555 AS y
        FROM __deinterleaved1
    ),
    __deinterleaved3 AS (
        SELECT
            z,
            (x | (x >> 1)) & 0x3333333333333333 AS x,
            (y | (y >> 1)) & 0x3333333333333333 AS y
        FROM __deinterleaved2
    ),
    __deinterleaved4 AS (
        SELECT
            z,
            (x | (x >> 2)) & 0x0F0F0F0F0F0F0F0F AS x,
            (y | (y >> 2)) & 0x0F0F0F0F0F0F0F0F AS y
        FROM __deinterleaved3
    ),
    __deinterleaved5 AS (
        SELECT
            z,
            (x | (x >> 4)) & 0x00FF00FF00FF00FF AS x,
            (y | (y >> 4)) & 0x00FF00FF00FF00FF AS y
        FROM __deinterleaved4
    ),
    __deinterleaved6 AS (
        SELECT
            z,
            (x | (x >> 8)) & 0x0000FFFF0000FFFF AS x,
            (y | (y >> 8)) & 0x0000FFFF0000FFFF AS y
        FROM __deinterleaved5
    ),
    __deinterleaved7 AS (
        SELECT
            z,
            (x | (x >> 16)) & 0x00000000FFFFFFFF AS x,
            (y | (y >> 16)) & 0x00000000FFFFFFFF AS y
        FROM __deinterleaved6
    )
    SELECT AS STRUCT
        z, (x >> (32-z)) AS x, (y >> (32-z)) AS y
    FROM __deinterleaved7
));