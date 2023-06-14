----------------------------
-- Copyright (C) 2022 CARTO
----------------------------


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS OBJECT
IMMUTABLE
AS $$
    CASE quadbin
        WHEN NULL THEN
            OBJECT_CONSTRUCT(NULL, NULL)
        ELSE (
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
                    4294967295          AS _0x00000000FFFFFFFF
            ),
            __interleaved AS (
                SELECT
                    BITAND(BITSHIFTRIGHT(quadbin::INT, 59), 7) AS mode,
                    BITAND(BITSHIFTRIGHT(quadbin::INT, 57), 3) AS mode_dep,
                    BITAND(BITSHIFTRIGHT(quadbin::INT, 52), _0X1F) AS z,
                    BITSHIFTLEFT(BITAND(quadbin::INT, _0x000FFFFFFFFFFFFF), 12) AS q
                FROM __hexConstants
            ),
            __deinterleaved1 AS (
                SELECT 
                    z,
                    q AS x,
                    BITSHIFTRIGHT(q, 1) AS y
                FROM __interleaved
            ),
            __deinterleaved2 AS (
                SELECT
                    z,
                    BITAND(x, _0x5555555555555555) AS x,
                    BITAND(y, _0x5555555555555555) AS y
                FROM __hexConstants, __deinterleaved1
            ),
            __deinterleaved3 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 1)), _0x3333333333333333) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 1)), _0x3333333333333333) AS y
                FROM __hexConstants, __deinterleaved2
            ),
            __deinterleaved4 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 2)), _0x0F0F0F0F0F0F0F0F) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 2)), _0x0F0F0F0F0F0F0F0F) AS y
                FROM __hexConstants, __deinterleaved3
            ),
            __deinterleaved5 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 4)), _0x00FF00FF00FF00FF) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 4)), _0x00FF00FF00FF00FF) AS y
                FROM __hexConstants, __deinterleaved4
            ),
            __deinterleaved6 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 8)), _0x0000FFFF0000FFFF) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 8)), _0x0000FFFF0000FFFF) AS y
                FROM __hexConstants, __deinterleaved5
            ),
            __deinterleaved7 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 16)), _0x00000000FFFFFFFF) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 16)), _0x00000000FFFFFFFF) AS y
                FROM __hexConstants, __deinterleaved6
            ),
            __result AS (
                SELECT
                    z as "z",
                    BITSHIFTRIGHT(x, (32 - z)) AS "x",
                    BITSHIFTRIGHT(y, (32 - z)) AS "y"
                FROM __deinterleaved7
            )
            SELECT
                OBJECT_CONSTRUCT(*)
            FROM __result)
    END
$$;
