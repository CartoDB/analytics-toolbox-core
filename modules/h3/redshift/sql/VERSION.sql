----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@h3.VERSION
() 
RETURNS VARCHAR 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@h3Lib import __version__
    return __version__
$$ LANGUAGE plpythonu;