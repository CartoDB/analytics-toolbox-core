----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_RESOLUTION
(BIGINT)
-- (quadbin)
RETURNS BIGINT
STABLE
AS $$
    SELECT ($1 >> 52) & CAST(31 AS BIGINT)
$$ LANGUAGE sql;
