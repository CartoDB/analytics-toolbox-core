----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_STRING_TOINT
(VARCHAR(MAX))
-- (quadbin)
RETURNS BIGINT
STABLE
AS $$
    SELECT CAST(FROM_HEX($1) AS BIGINT)
$$ LANGUAGE SQL;
