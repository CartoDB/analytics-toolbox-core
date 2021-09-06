----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.TOPARENT
(quadint BIGINT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import to_parent
    
    if quadint is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return to_parent(quadint, resolution)
$$ LANGUAGE plpythonu;