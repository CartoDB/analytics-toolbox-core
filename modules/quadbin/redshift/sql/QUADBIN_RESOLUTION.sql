----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_RESOLUTION
(BIGINT)
-- (quadbin)
RETURNS BIGINT
IMMUTABLE
AS $$
    SELECT ($1 >> 52) & CAST(31 AS BIGINT)
$$ LANGUAGE sql;
