----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.HILBERTQUADKEY_FROMID
(id INT8) 
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@s2Lib import id_to_hilbert_quadkey

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return id_to_hilbert_quadkey(id)
    
$$ LANGUAGE plpythonu;
