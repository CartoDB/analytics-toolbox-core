----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_BOUNDARY(
    id BIGINT
) 
RETURNS VARCHAR(MAX) 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import get_cell_bounds
    
    return get_cell_bounds(long(id))
    
$$ LANGUAGE plpythonu;
