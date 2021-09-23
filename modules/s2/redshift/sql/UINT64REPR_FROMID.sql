----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.UINT64REPR_FROMID
(id INT8) 
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import uint64_repr_from_id

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return str(uint64_repr_from_id(id))
    
$$ LANGUAGE plpythonu;
