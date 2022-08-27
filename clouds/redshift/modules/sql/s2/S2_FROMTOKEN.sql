----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_FROMTOKEN
(token VARCHAR(MAX)) 
RETURNS INT8
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import token_to_int64_id

    if token is None:
        raise Exception('NULL argument passed to UDF')
    
    return token_to_int64_id(token)
    
$$ LANGUAGE plpythonu;
