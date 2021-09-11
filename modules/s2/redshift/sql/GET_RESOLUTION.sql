----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.GET_RESOLUTION(
    id BIGINT
)
RETURNS INTEGER 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import get_resolution
    
    return get_resolution(long(id))
    
$$ LANGUAGE plpythonu;
