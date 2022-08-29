----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_TOHILBERTQUADKEY
(id INT8) 
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import id_to_hilbert_quadkey

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return id_to_hilbert_quadkey(id)
    
$$ LANGUAGE plpythonu;
