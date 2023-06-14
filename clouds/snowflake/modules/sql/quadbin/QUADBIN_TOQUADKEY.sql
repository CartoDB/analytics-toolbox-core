----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._TO_BASE
(NUM FLOAT, RADIX FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return parseFloat((NUM.toString(RADIX)));
$$;


CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOQUADKEY
(quadbin BIGINT)
RETURNS VARCHAR
IMMUTABLE
AS $$
    CASE quadbin
        WHEN NULL THEN
            ''
        ELSE (
            WITH
            __hexConstants AS (
                SELECT
                    31 AS _0X1F,
                    4503599627370495 AS _0x000FFFFFFFFFFFFF
            ),
            __z AS (
                SELECT
                    BITAND(BITSHIFTRIGHT(quadbin, 52), _0X1F) AS z
                FROM __hexConstants
            ),
            __xy AS (
                SELECT
                    BITSHIFTRIGHT(
                        BITAND(quadbin, _0x000FFFFFFFFFFFFF),
                        (52 - z*2)
                    ) AS xy
                FROM __z, __hexConstants
            )
            SELECT
                CASE
                    WHEN z = 0 THEN
                        ''
                    ELSE
                        LTRIM(
                            TO_VARCHAR(
                                @@SF_SCHEMA@@._TO_BASE(xy, 4),
                                -- FM as fill modifier otherwise a space is added at the beginning
                                'FM' || REPEAT('0', z) -- e.g 'FM000000000000'
                            ),
                            ' '
                        )
                END
            FROM __z, __xy
        )
    END
$$;
