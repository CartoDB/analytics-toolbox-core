----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMZXY
(z INT, x INT, y INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    WITH
    __ints AS (
        SELECT
            z AS zz,
            BITSHIFTLEFT(x, (32 - z)) AS xx,
            BITSHIFTLEFT(y, (32 - z)) AS yy
    ),
    __interleaved1 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 16)), 281470681808895) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 16)), 281470681808895) AS yy,
            zz
        FROM __ints
    ),
    __interleaved2 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 8)), 71777214294589695) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 8)), 71777214294589695) AS yy,
            zz
        FROM __interleaved1
    ),
    __interleaved3 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 4)), 1085102592571150095) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 4)), 1085102592571150095) AS yy,
            zz
        FROM __interleaved2
    ),
    __interleaved4 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 2)), 3689348814741910323) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 2)), 3689348814741910323) AS yy,
            zz
        FROM __interleaved3
    ),
    __interleaved5 AS (
        SELECT
            BITAND(BITOR(xx, BITSHIFTLEFT(xx, 1)), 6148914691236517205) AS xx,
            BITAND(BITOR(yy, BITSHIFTLEFT(yy, 1)), 6148914691236517205) AS yy,
            zz
        FROM __interleaved4
    )
    SELECT
        BITOR(
            4611686018427387904,
            BITOR(
                BITSHIFTLEFT(1, 59), -- | (mode << 59) | (mode_dep << 57)
                BITOR(
                    BITSHIFTLEFT(zz, 52),
                    BITOR(
                        BITSHIFTRIGHT(BITOR(xx, BITSHIFTLEFT(yy, 1)), 12),
                        BITSHIFTRIGHT(4503599627370495, (zz * 2))
                    )
                )
            )
        )
    FROM __interleaved5
 $$;