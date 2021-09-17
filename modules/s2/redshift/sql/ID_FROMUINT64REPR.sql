----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ID_FROMUINT64REPR(
    uint64_id VARCHAR(MAX)
) 
RETURNS INT8
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import uint64_to_int64
    
    return uint64_to_int64(int(uint64_id))
    
$$ LANGUAGE plpythonu;
