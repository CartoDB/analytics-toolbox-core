----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._QUADINT_FROMQUADKEY
(quadkey VARCHAR)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadintFromQuadkey
    return str(quadintFromQuadkey(quadkey))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADINT_FROMQUADKEY
(VARCHAR)
-- (quadkey)
RETURNS BIGINT
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@quadkey._QUADINT_FROMQUADKEY($1)::BIGINT
$$ LANGUAGE sql;