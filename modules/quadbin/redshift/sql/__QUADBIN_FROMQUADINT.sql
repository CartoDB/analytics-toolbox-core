
----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_FROMQUADINT
(quadint BIGINT)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_from_zxy
    
    z = quadint & 31
    x = (quadint >> 5) & ((1 << z) - 1)
    y = quadint >> (z + 5)

    return quadbin_from_zxy(z, x, y)
$$ LANGUAGE plpythonu;
