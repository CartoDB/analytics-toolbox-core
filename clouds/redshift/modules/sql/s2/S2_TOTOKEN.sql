----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_TOTOKEN
(id INT8)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import int64_id_to_token

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return int64_id_to_token(id)
    
$$ LANGUAGE plpythonu;
