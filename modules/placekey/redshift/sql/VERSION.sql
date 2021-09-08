----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@placekey.VERSION
() 
RETURNS VARCHAR 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@placekeyLib import __version__
    return __version__
$$ LANGUAGE plpythonu;