----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMZXY
(z INT, x INT, y INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    WITH
    __hexConstants AS (
        SELECT
            31 AS _0X1F,
            4503599627370495    AS _0x000FFFFFFFFFFFFF,
            6148914691236517205 AS _0x5555555555555555, -- 0101
            3689348814741910323 AS _0x3333333333333333, -- 0011
            1085102592571150095 AS _0x0F0F0F0F0F0F0F0F, -- 1111
            71777214294589695   AS _0x00FF00FF00FF00FF,
            281470681808895     AS _0x0000FFFF0000FFFF,
            4294967295          AS _0x00000000FFFFFFFF,
            4611686018427387904 AS _0x4000000000000000
    ),
    __ints AS (
        SELECT
            z AS zz,
            BITSHIFTLEFT(x, (32 - z)) AS xx,
            BITSHIFTLEFT(y, (32 - z)) AS yy
    ),
    __interleaved1 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 16)), _0x0000FFFF0000FFFF) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 16)), _0x0000FFFF0000FFFF) AS yy,
            zz
        FROM __ints, __hexConstants
    ),
    __interleaved2 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 8)), _0x00FF00FF00FF00FF) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 8)), _0x00FF00FF00FF00FF) AS yy,
            zz
        FROM __interleaved1, __hexConstants
    ),
    __interleaved3 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 4)), _0x0F0F0F0F0F0F0F0F) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 4)), _0x0F0F0F0F0F0F0F0F) AS yy,
            zz
        FROM __interleaved2, __hexConstants
    ),
    __interleaved4 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 2)), _0x3333333333333333) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 2)), _0x3333333333333333) AS yy,
            zz
        FROM __interleaved3, __hexConstants
    ),
    __interleaved5 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 1)), _0x5555555555555555) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 1)), _0x5555555555555555) AS yy,
            zz
        FROM __interleaved4, __hexConstants
    )
    SELECT
        BITOR(
            _0x4000000000000000,
            BITOR(
                BITSHIFTLEFT(1, 59), -- | (mode << 59) | (mode_dep << 57)
                BITOR(
                    BITSHIFTLEFT(zz, 52),
                    BITOR(
                        BITSHIFTRIGHT(BITOR(xx, BITSHIFTLEFT(yy, 1)), 12),
                        BITSHIFTRIGHT(_0x000FFFFFFFFFFFFF, (zz * 2))
                    )
                )
            )
        )
    FROM __interleaved5, __hexConstants
 $$;