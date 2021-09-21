----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.VERSION() 
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import __version__
    return __version__
$$ LANGUAGE plpythonu;