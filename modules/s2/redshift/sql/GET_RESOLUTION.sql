----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.GET_RESOLUTION(
    id INT8
)
RETURNS INTEGER 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import get_resolution
    
    return get_resolution(id)
    
$$ LANGUAGE plpythonu;
