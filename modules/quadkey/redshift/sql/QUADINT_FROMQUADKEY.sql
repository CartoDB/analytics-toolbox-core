----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADINT_FROMQUADKEY
(quadkey VARCHAR)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadint_from_quadkey
    return quadint_from_quadkey(quadkey)
$$ LANGUAGE plpythonu;