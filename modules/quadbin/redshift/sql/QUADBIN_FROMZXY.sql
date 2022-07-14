----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_FROMZXY
(z BIGINT, x BIGINT, y BIGINT)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_from_zxy
    return quadbin_from_zxy(z, x, y)
$$ LANGUAGE plpythonu;
