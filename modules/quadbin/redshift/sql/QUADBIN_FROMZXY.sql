----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_FROMZXY
(z INT, x INT, y INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_from_zxy
    return quadbin_from_zxy(z, x, y)
$$ LANGUAGE plpythonu;
