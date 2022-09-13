----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_FROMUINT64REPR
(uid VARCHAR(MAX))
RETURNS INT8
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import uint64_to_int64

    if uid is None:
        raise Exception('NULL argument passed to UDF')
    
    return uint64_to_int64(int(uid))
    
$$ LANGUAGE PLPYTHONU;
