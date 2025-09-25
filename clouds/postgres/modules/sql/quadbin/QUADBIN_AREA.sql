----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_AREA(
    quadbin BIGINT
)
RETURNS FLOAT
AS
$BODY$
    SELECT
        CASE
            WHEN quadbin IS NULL THEN NULL
            ELSE ST_AREA(@@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin))
        END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;