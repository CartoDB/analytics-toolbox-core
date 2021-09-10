----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADKEY_FROMQUADINT
(quadint BIGINT)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadkey_from_quadint
    
    if quadint is None:
        raise Exception('NULL argument passed to UDF')
    
    return quadkey_from_quadint(quadint)
$$ LANGUAGE plpythonu;