----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ID_FROMHILBERTQUADKEY(
    hilbert_quadkey VARCHAR(MAX)
) 
RETURNS INT8
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import hilbert_quadkey_to_id

    if hilbert_quadkey is None:
        raise Exception('NULL argument passed to UDF')
    
    return hilbert_quadkey_to_id(hilbert_quadkey)
    
$$ LANGUAGE plpythonu;
