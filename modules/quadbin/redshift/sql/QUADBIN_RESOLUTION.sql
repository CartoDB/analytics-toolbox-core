----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_RESOLUTION
(BIGINT)
-- (quadbin)
RETURNS BIGINT
STABLE
AS $$
    SELECT ($1 >> 52) & CAST(31 AS BIGINT)
$$ LANGUAGE sql;