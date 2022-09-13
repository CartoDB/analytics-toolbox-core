----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_INT_TOSTRING
(BIGINT)
-- (quadbin)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT TO_HEX($1)
$$ LANGUAGE SQL;
