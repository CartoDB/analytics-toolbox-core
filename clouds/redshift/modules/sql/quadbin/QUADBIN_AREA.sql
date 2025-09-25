----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_AREA
(BIGINT)
-- (quadbin)
RETURNS FLOAT
STABLE
AS $$
    SELECT
        CASE
            WHEN $1 IS NULL THEN NULL
            ELSE ST_AREA(@@RS_SCHEMA@@.QUADBIN_BOUNDARY($1))
        END
$$ LANGUAGE sql;