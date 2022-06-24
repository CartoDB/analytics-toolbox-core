----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_FROMZXY
(_z INT, _x INT, _y INT)
RETURNS INT
AS $$
    WITH
        __ints AS (
            SELECT BITSHIFTLEFT(cast(_x AS int), (32-_z)) AS x, BITSHIFTLEFT(cast(_y AS int), (32-_z)) AS y, _z AS z
        ),
        __interleaved1 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 16)), 281470681808895) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 16)), 281470681808895) AS y,
            z
            FROM __ints
        ),
        __interleaved2 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 8)), 71777214294589695) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 8)), 71777214294589695) AS y,
            z
            FROM __interleaved1
        ),
        __interleaved3 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 4)), 1085102592571150095) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 4)), 1085102592571150095) AS y,
            z
            FROM __interleaved2
        ),
        __interleaved4 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 2)), 3689348814741910323) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 2)), 3689348814741910323) AS y,
            z
            FROM __interleaved3
        ),
        __interleaved5 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 1)), 6148914691236517205) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 1)), 6148914691236517205) AS y,
            z
            FROM __interleaved4
        )
        SELECT
            BITOR(
                BITOR(
                    BITOR(
                        BITOR(
                            4611686018427387904,
                            BITSHIFTLEFT(1, 59)
                        ),
                        BITSHIFTLEFT(z, 52)
                    ),
                    BITSHIFTRIGHT(
                        BITOR(
                            x,
                            BITSHIFTLEFT(y, 1)
                        ),
                        12
                    )
                ),
                BITSHIFTLEFT(
                    1,
                    52 - BITSHIFTLEFT(z, 1)
                ) - 1
            )
        FROM __interleaved5
$$;