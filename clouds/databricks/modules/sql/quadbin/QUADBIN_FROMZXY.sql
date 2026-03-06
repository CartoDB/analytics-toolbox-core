----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts z/x/y tile coordinates to a quadbin index using Morton/Z-order
-- interleaving of the x and y bits.
--
-- Bit-mask constants (decimal equivalents of hex for Databricks compatibility):
--   281470681808895    = 0x0000FFFF0000FFFF
--   71777214294589695  = 0x00FF00FF00FF00FF
--   1085102592571150095 = 0x0F0F0F0F0F0F0F0F
--   3689348814741910323 = 0x3333333333333333
--   6148914691236517205 = 0x5555555555555555
--   4611686018427387904 = 0x4000000000000000 (header)
--   4503599627370495    = 0xFFFFFFFFFFFFF (unused bits mask)

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_FROMZXY
(z INT, x INT, y INT)
RETURNS BIGINT
RETURN (
    IF(z IS NULL OR x IS NULL OR y IS NULL, NULL,
        (WITH __ints AS (
            SELECT
                z AS zz,
                CAST(x AS BIGINT) << (32 - z) AS xx,
                CAST(y AS BIGINT) << (32 - z) AS yy
        ),
        __i1 AS (
            SELECT
                (xx | (xx << 16)) & CAST(281470681808895 AS BIGINT) AS xx,
                (yy | (yy << 16)) & CAST(281470681808895 AS BIGINT) AS yy,
                zz
            FROM __ints
        ),
        __i2 AS (
            SELECT
                (xx | (xx << 8)) & CAST(71777214294589695 AS BIGINT) AS xx,
                (yy | (yy << 8)) & CAST(71777214294589695 AS BIGINT) AS yy,
                zz
            FROM __i1
        ),
        __i3 AS (
            SELECT
                (xx | (xx << 4)) & CAST(1085102592571150095 AS BIGINT) AS xx,
                (yy | (yy << 4)) & CAST(1085102592571150095 AS BIGINT) AS yy,
                zz
            FROM __i2
        ),
        __i4 AS (
            SELECT
                (xx | (xx << 2)) & CAST(3689348814741910323 AS BIGINT) AS xx,
                (yy | (yy << 2)) & CAST(3689348814741910323 AS BIGINT) AS yy,
                zz
            FROM __i3
        ),
        __i5 AS (
            SELECT
                (xx | (xx << 1)) & CAST(6148914691236517205 AS BIGINT) AS xx,
                (yy | (yy << 1)) & CAST(6148914691236517205 AS BIGINT) AS yy,
                zz
            FROM __i4
        )
        SELECT
            CAST(4611686018427387904 AS BIGINT)
            | (CAST(1 AS BIGINT) << 59)
            | (CAST(zz AS BIGINT) << 52)
            | shiftrightunsigned(xx | (yy << 1), 12)
            | shiftrightunsigned(CAST(4503599627370495 AS BIGINT), zz * 2)
        FROM __i5)
    )
);
