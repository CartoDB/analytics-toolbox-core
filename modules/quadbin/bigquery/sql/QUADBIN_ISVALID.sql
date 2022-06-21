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
                quadbin >= 0 AND (quadbin & 0x4000000000000000 = 0x4000000000000000)
                AND ((quadbin >> 59) & 7) IN (0,1,2,3,4,5,6) -- modes; note mode=0 is not valid
                AND tile.z >= 0 AND tile.z <= 26
                -- TODO: check unused trailing bits are 1s
            FROM __zxy
        )
    END
);