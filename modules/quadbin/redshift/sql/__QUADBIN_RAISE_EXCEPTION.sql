----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_RAISE_EXCEPTION
(error_msg VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    raise Exception(error_msg)
$$ LANGUAGE plpythonu;