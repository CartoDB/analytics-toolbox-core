----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_TOPARENT
(quadbin BIGINT, resolution INT)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import to_parent
    
    if quadbin is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return to_parent(quadbin, resolution)
$$ LANGUAGE plpythonu;