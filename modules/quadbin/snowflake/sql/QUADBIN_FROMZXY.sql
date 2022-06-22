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
            BITAND(BITOR(x, BITSHIFTLEFT(x, 16)), TO_NUMBER('0000ffff0000ffff', 'XXXXXXXXXXXXXXXX')) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 16)), TO_NUMBER('0000ffff0000ffff', 'XXXXXXXXXXXXXXXX')) AS y,
            z
            FROM __ints
        ),
        __interleaved2 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 8)), TO_NUMBER('00ff00ff00ff00ff', 'XXXXXXXXXXXXXXXX')) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 8)), TO_NUMBER('00ff00ff00ff00ff', 'XXXXXXXXXXXXXXXX')) AS y,
            z
            FROM __interleaved1
        ),
        __interleaved3 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 4)), TO_NUMBER('0f0f0f0f0f0f0f0f', 'XXXXXXXXXXXXXXXX')) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 4)), TO_NUMBER('0f0f0f0f0f0f0f0f', 'XXXXXXXXXXXXXXXX')) AS y,
            z
            FROM __interleaved2
        ),
        __interleaved4 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 2)), TO_NUMBER('3333333333333333', 'XXXXXXXXXXXXXXXX')) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 2)), TO_NUMBER('3333333333333333', 'XXXXXXXXXXXXXXXX')) AS y,
            z
            FROM __interleaved3
        ),
        __interleaved5 AS (
            SELECT
            BITAND(BITOR(x, BITSHIFTLEFT(x, 1)), TO_NUMBER('5555555555555555', 'XXXXXXXXXXXXXXXX')) AS x,
            BITAND(BITOR(y, BITSHIFTLEFT(y, 1)), TO_NUMBER('5555555555555555', 'XXXXXXXXXXXXXXXX')) AS y,
            z
            FROM __interleaved4
        )
        SELECT 
            BITOR(
                BITOR(
                    BITOR(
                        BITOR(
                            TO_NUMBER('4000000000000000', 'xxxxxxxxxxxxxxxx'),
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