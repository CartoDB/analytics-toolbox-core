----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_FROMZXY`
(z INT64, x INT64, y INT64)
RETURNS INT64
AS ((
    WITH __ints AS (
        SELECT
            z,
            CAST(x AS INT64) << (32 - z) AS x,
            CAST(y AS INT64) << (32 - z) AS y
    ),
    __interleaved1 AS (
        SELECT
            (x | (x << 16)) & 0x0000FFFF0000FFFF AS x,
            (y | (y << 16)) & 0x0000FFFF0000FFFF AS y,
            z
        FROM __ints
    ),
    __interleaved2 AS (
        SELECT
            (x | (x << 8)) & 0x00FF00FF00FF00FF AS x,
            (y | (y << 8)) & 0x00FF00FF00FF00FF AS y,
            z
        FROM __interleaved1
    ),
    __interleaved3 AS (
        SELECT
            (x | (x << 4)) & 0x0F0F0F0F0F0F0F0F AS x,
            (y | (y << 4)) & 0x0F0F0F0F0F0F0F0F AS y,
            z
        FROM __interleaved2
    ),
    __interleaved4 AS (
        SELECT
            (x | (x << 2)) & 0x3333333333333333 AS x,
            (y | (y << 2)) & 0x3333333333333333 AS y,
            z
        FROM __interleaved3
    ),
    __interleaved5 AS (
        SELECT
            (x | (x << 1)) & 0x5555555555555555 AS x,
            (y | (y << 1)) & 0x5555555555555555 AS y,
            z
        FROM __interleaved4
    )
    SELECT
        0x4000000000000000
        | (1 << 59) -- | (mode << 59) | (mode_dep << 57)
        | (z << 52)
        | ((x | (y << 1)) >> 12)
        | (0xFFFFFFFFFFFFF >> (z * 2))
    FROM __interleaved5
));
