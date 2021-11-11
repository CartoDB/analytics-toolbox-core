----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.S2_UINT64REPRFROMID
(id INT8) 
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@s2Lib import uint64_repr_from_id

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return str(uint64_repr_from_id(id))
    
$$ LANGUAGE plpythonu;
