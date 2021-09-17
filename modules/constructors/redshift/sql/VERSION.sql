----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.VERSION
() 
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@constructorsLib import __version__
    return __version__
$$ LANGUAGE plpythonu;