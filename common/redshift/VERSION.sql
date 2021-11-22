----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.VERSION
() 
RETURNS VARCHAR 
IMMUTABLE
AS $$
    return '1.0.0'
$$ LANGUAGE plpythonu;