----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.SIBLING
(quadint BIGINT, direction VARCHAR)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import sibling
    
    if quadint is None or direction is None:
        raise Exception('NULL argument passed to UDF')

    return sibling(quadint, direction)
$$ LANGUAGE plpythonu;