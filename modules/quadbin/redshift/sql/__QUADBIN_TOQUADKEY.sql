----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_TOQUADKEY
(quadbin BIGINT)
RETURNS VARCHAR
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadkey_from_quadbin
    
    if quadbin is None:
        return None
    
    return quadkey_from_quadbin(quadbin)
$$ LANGUAGE plpythonu;