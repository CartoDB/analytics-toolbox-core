----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_TOZXY_Y
(BIGINT)
-- (quadbin)
RETURNS BIGINT
STABLE
AS $$
    SELECT @@RS_SCHEMA@@.__QUADBIN_TOZXY_X($1 >> 1)
$$ LANGUAGE sql;
