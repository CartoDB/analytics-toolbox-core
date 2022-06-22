----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_ISVALID
(quadbin INT)
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
                tile:z >= 0 AND tile:z <= 29 AND
                BITAND(quadbin, (BITSHIFTLEFT(1, (59 - 2 * tile:z)) - 1)) = 0
            FROM __zxy
        )
    END
$$;