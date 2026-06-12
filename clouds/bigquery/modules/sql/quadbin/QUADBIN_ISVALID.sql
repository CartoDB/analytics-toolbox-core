----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_ISVALID`
(quadbin INT64)
RETURNS BOOLEAN
AS (
    CASE quadbin
        WHEN NULL THEN
            FALSE
        ELSE (
            WITH
            __params AS (
                SELECT
                    (quadbin >> 59) & 7 AS mode,
                    (quadbin >> 52) & 0x1F AS z,
                    0x4000000000000000 AS header,
                    (0xFFFFFFFFFFFFF >> (((quadbin >> 52) & 0x1F) * 2)) AS unused
            )
            SELECT
                quadbin >= 0
                AND (quadbin & header = header)
                AND mode IN (0, 1, 2, 3, 4, 5, 6)
                AND z >= 0
                AND z <= 26
                AND (quadbin & unused = unused)
            FROM __params
        )
    END
);
