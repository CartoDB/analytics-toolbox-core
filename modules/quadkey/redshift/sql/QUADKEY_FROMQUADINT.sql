----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._QUADKEY_FROMQUADINT
(quadint VARCHAR)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadkeyFromQuadint
    
    if quadint is None:
        raise Exception('NULL argument passed to UDF')
    
    return str(quadkeyFromQuadint(quadint))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADKEY_FROMQUADINT
(BIGINT)
-- (quadint)
RETURNS VARCHAR
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@quadkey._QUADKEY_FROMQUADINT($1::VARCHAR)
$$ LANGUAGE sql;