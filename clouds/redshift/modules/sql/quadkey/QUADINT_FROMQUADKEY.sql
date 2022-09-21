----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_FROMQUADKEY
(quadkey VARCHAR)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_LIBRARY@@.quadkey import quadint_from_quadkey
    return quadint_from_quadkey(quadkey)
$$ LANGUAGE plpythonu;
