----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_TOUINT64REPR
(id INT8)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import uint64_repr_from_id

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return str(uint64_repr_from_id(id))
    
$$ LANGUAGE plpythonu;
