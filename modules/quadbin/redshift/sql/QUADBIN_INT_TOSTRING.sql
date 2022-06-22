----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_INT_TOSTRING
(BIGINT)
-- (quadbin)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    select to_hex($1)
$$ LANGUAGE sql;