----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_FROMHILBERTQUADKEY
(hquadkey VARCHAR(MAX)) 
RETURNS INT8
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import hilbert_quadkey_to_id

    if hquadkey is None:
        raise Exception('NULL argument passed to UDF')
    
    return hilbert_quadkey_to_id(hquadkey)
    
$$ LANGUAGE plpythonu;
