----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_BOUNDARY
(id INT8) 
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@s2Lib import get_cell_boundary

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return get_cell_boundary(id)
    
$$ LANGUAGE plpythonu;
