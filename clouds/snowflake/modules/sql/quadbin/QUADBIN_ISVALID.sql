----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_ISVALID
(quadbin BIGINT)
RETURNS BOOLEAN
IMMUTABLE
AS $$
    CASE quadbin
        WHEN NULL THEN
            FALSE
        ELSE (
            WITH
            __params AS (
                SELECT
                    BITAND(BITSHIFTRIGHT(quadbin, 59), 7) AS mode,
                    BITAND(BITSHIFTRIGHT(quadbin, 52), 31) AS z,
                    4611686018427387904 AS header,
                    BITSHIFTRIGHT(4503599627370495, (BITAND(BITSHIFTRIGHT(quadbin, 52), 31) * 2)) AS unused
            )
            SELECT
                quadbin >= 0
                AND BITAND(quadbin, header) = header
                AND mode IN (0,1,2,3,4,5,6)
                AND z >= 0
                AND z <= 26
                AND BITAND(quadbin, unused) = unused
            FROM __params
        )
    END
$$;
