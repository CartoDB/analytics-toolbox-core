----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_SIBLING
(quadbin BIGINT, direction VARCHAR)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import sibling
    
    if quadbin is None or direction is None:
        raise Exception('NULL argument passed to UDF')

    return sibling(quadbin, direction)
$$ LANGUAGE plpythonu;