----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Extracts z/x/y tile coordinates from a quadbin index by de-interleaving
-- the Morton-coded bits.
--
-- Bit-mask constants (decimal equivalents):
--   6148914691236517205 = 0x5555555555555555
--   3689348814741910323 = 0x3333333333333333
--   1085102592571150095 = 0x0F0F0F0F0F0F0F0F
--   71777214294589695   = 0x00FF00FF00FF00FF
--   281470681808895     = 0x0000FFFF0000FFFF
--   4294967295          = 0x00000000FFFFFFFF
--   4503599627370495    = 0xFFFFFFFFFFFFF (52-bit mask)

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS STRUCT<z: INT, x: INT, y: INT>
RETURN (
    IF(
        quadbin IS NULL, NULL,
        (
            WITH
            __interleaved AS (
                SELECT
                    CAST((quadbin >> 52) & CAST(31 AS BIGINT) AS INT) AS z,
                    (quadbin & CAST(4503599627370495 AS BIGINT)) << 12 AS q
            ),

            __d1 AS (
                SELECT
                    z,
                    q AS x,
                    SHIFTRIGHTUNSIGNED(q, 1) AS y
                FROM __interleaved
            ),

            __d2 AS (
                SELECT
                    z,
                    x & CAST(6148914691236517205 AS BIGINT) AS x,
                    y & CAST(6148914691236517205 AS BIGINT) AS y
                FROM __d1
            ),

            __d3 AS (
                SELECT
                    z,
                    (x | (x >> 1)) & CAST(3689348814741910323 AS BIGINT) AS x,
                    (y | (y >> 1)) & CAST(3689348814741910323 AS BIGINT) AS y
                FROM __d2
            ),

            __d4 AS (
                SELECT
                    z,
                    (x | (x >> 2)) & CAST(1085102592571150095 AS BIGINT) AS x,
                    (y | (y >> 2)) & CAST(1085102592571150095 AS BIGINT) AS y
                FROM __d3
            ),

            __d5 AS (
                SELECT
                    z,
                    (x | (x >> 4)) & CAST(71777214294589695 AS BIGINT) AS x,
                    (y | (y >> 4)) & CAST(71777214294589695 AS BIGINT) AS y
                FROM __d4
            ),

            __d6 AS (
                SELECT
                    z,
                    (x | (x >> 8)) & CAST(281470681808895 AS BIGINT) AS x,
                    (y | (y >> 8)) & CAST(281470681808895 AS BIGINT) AS y
                FROM __d5
            ),

            __d7 AS (
                SELECT
                    z,
                    (x | (x >> 16)) & CAST(4294967295 AS BIGINT) AS x,
                    (y | (y >> 16)) & CAST(4294967295 AS BIGINT) AS y
                FROM __d6
            )

            SELECT
                NAMED_STRUCT(
                    'z', z,
                    'x', CAST((x >> (32 - z)) AS INT),
                    'y', CAST((y >> (32 - z)) AS INT)
                )
            FROM __d7
        )
    )
);
