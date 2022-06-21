----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_ISVALID`
(quadbin INT64)
RETURNS BOOLEAN
AS (
    CASE
        WHEN quadbin IS NULL THEN
            FALSE
        ELSE (
            WITH
            __zxy AS (
                SELECT
                    `@@BQ_PREFIX@@carto.QUADBIN_TOZXY`(quadbin) AS tile
            )
            SELECT
                tile.z >= 0 AND tile.z <= 29 AND
                (quadbin & ((1 << (59 - 2 * tile.z)) - 1)) = 0
            FROM __zxy
        )
    END
);