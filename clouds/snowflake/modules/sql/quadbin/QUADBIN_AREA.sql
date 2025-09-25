----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_AREA
(quadbin BIGINT)
RETURNS FLOAT
IMMUTABLE
AS $$
    SELECT
        CASE
            WHEN QUADBIN IS NULL THEN NULL
            ELSE ST_AREA(@@SF_SCHEMA@@.QUADBIN_BOUNDARY(QUADBIN))
        END
$$;