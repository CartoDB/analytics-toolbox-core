----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.VERSION
() 
RETURNS VARCHAR 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import __version__
    return __version__
$$ LANGUAGE plpythonu;