----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_ISVALID
(quadbin BIGINT)
RETURNS BOOLEAN
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_is_valid

    if quadbin is None:
        return False

    return quadbin_is_valid(quadbin)
$$ LANGUAGE plpythonu;
