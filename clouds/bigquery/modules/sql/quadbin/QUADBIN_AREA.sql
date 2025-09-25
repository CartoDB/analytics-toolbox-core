----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_AREA`(
    quadbin INT64
)
RETURNS FLOAT64
AS (
    CASE quadbin
        WHEN NULL THEN
            NULL
        ELSE
            ST_AREA(`@@BQ_DATASET@@.QUADBIN_BOUNDARY`(quadbin))
    END
);