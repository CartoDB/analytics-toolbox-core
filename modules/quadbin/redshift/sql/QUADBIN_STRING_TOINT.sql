----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_STRING_TOINT
(VARCHAR(MAX))
-- (quadbin)
RETURNS BIGINT
STABLE
AS $$
    SELECT CAST(FROM_HEX($1) AS BIGINT)
$$ LANGUAGE sql;
