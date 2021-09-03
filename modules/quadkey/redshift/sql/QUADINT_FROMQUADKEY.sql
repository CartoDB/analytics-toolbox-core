----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADINT_FROMQUADKEY
(quadkey VARCHAR)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadintFromQuadkey
    return quadintFromQuadkey(quadkey)
$$ LANGUAGE plpythonu;
