----------------------------
-- Copyright (C) 2022-2023 CARTO
----------------------------


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
            __z AS (
                SELECT
                    BITAND(BITSHIFTRIGHT(quadbin, 52), 31) AS z
            ),
            __xy AS (
                SELECT
                    BITSHIFTRIGHT(
                        BITAND(quadbin, 4503599627370495),
                        (52 - z*2)
                    ) AS xy
                FROM __z
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
