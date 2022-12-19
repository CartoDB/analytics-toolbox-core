----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_TOQUADKEY
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from numpy import base_repr
    q = quadbin
    z = (q >> 52) & (0x1F)
    xy = (q & 0xFFFFFFFFFFFFF) >> (52 - z * 2)
    return base_repr(xy, 4).zfill(z) if z != 0 else ''
$$ LANGUAGE plpythonu;
