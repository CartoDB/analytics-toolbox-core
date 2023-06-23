----------------------------
-- Copyright (C) 2022-2023 CARTO
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
            __interleaved AS (
                SELECT
                    BITAND(BITSHIFTRIGHT(quadbin::INT, 59), 7) AS mode,
                    BITAND(BITSHIFTRIGHT(quadbin::INT, 57), 3) AS mode_dep,
                    BITAND(BITSHIFTRIGHT(quadbin::INT, 52), 31) AS z,
                    BITSHIFTLEFT(BITAND(quadbin::INT, 4503599627370495), 12) AS q
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
                    BITAND(x, 6148914691236517205) AS x,
                    BITAND(y, 6148914691236517205) AS y
                FROM __deinterleaved1
            ),
            __deinterleaved3 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 1)), 3689348814741910323) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 1)), 3689348814741910323) AS y
                FROM __deinterleaved2
            ),
            __deinterleaved4 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 2)), 1085102592571150095) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 2)), 1085102592571150095) AS y
                FROM __deinterleaved3
            ),
            __deinterleaved5 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 4)), 71777214294589695) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 4)), 71777214294589695) AS y
                FROM __deinterleaved4
            ),
            __deinterleaved6 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 8)), 281470681808895) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 8)), 281470681808895) AS y
                FROM __deinterleaved5
            ),
            __deinterleaved7 AS (
                SELECT
                    z,
                    BITAND(BITOR(x, BITSHIFTRIGHT(x, 16)), 4294967295) AS x,
                    BITAND(BITOR(y, BITSHIFTRIGHT(y, 16)), 4294967295) AS y
                FROM __deinterleaved6
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
