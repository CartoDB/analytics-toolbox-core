----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMQUADKEY
(quadkey STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    WITH
    __params AS (
        SELECT
            LEN(quadkey) AS z,
            (CASE
                WHEN TRY_TO_NUMBER(quadkey) IS NULL THEN 
                    0
                ELSE
                    TO_NUMBER(
                        @@SF_SCHEMA@@._FROM_BASE(TRY_TO_NUMBER(quadkey), 4)
                    )
            END) AS xy
    ),
    __prepared AS (
        SELECT
            BITSHIFTLEFT(1, 59) AS param1,
            BITSHIFTLEFT(z, 52) AS param2,
            BITSHIFTLEFT(xy, (52-(z*2))) AS param3,
            BITSHIFTRIGHT(4503599627370495, (z*2)) AS param4
        FROM __params
    )
    SELECT
        BITOR(4611686018427387904,
            BITOR(param1,
                BITOR(param2,
                    BITOR(param3, param4))))
    FROM __prepared
$$;
