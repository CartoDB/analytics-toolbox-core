----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_ISVALID
(quadbin BIGINT)
RETURNS BOOLEAN
AS $$
    CASE
        WHEN quadbin IS NULL THEN
            FALSE
        ELSE (
            WITH
            __zxy AS (
                SELECT
                    QUADBIN_TOZXY(quadbin) AS tile
            )
            SELECT
                quadbin >= 0
                AND BITAND(quadbin, TO_NUMBER('4000000000000000', 'xxxxxxxxxxxxxxxx'))
                    = TO_NUMBER('4000000000000000', 'xxxxxxxxxxxxxxxx')
                AND BITAND(BITSHIFTRIGHT(quadbin, 59), 7) IN (0,1,2,3,4,5,6) -- modes
                AND tile:z >= 0 AND tile:z <= 26
            FROM __zxy
        )
    END
$$;

