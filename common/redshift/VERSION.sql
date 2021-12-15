----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.@@RS_VERSION_FUNCTION@@
() 
RETURNS VARCHAR 
IMMUTABLE
AS $$
    return '@@RS_PACKAGE_VERSION@@';
$$ LANGUAGE plpythonu;