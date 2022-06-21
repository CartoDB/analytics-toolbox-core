----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_FROMQUADKEY
(quadkey VARCHAR)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_from_quadkey
    return quadbin_from_quadkey(quadkey)
$$ LANGUAGE plpythonu;