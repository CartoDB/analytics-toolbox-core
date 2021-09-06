----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._BBOX
(quadint BIGINT)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import bbox
    
    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    quadint_bbox = bbox(quadint)
    return '[' + str(quadint_bbox.west) + ',' + str(quadint_bbox.south) + ',' + str(quadint_bbox.east) + ',' + str(quadint_bbox.north) + ']'
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.BBOX
(BIGINT)
-- (quadint)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@quadkey._BBOX($1))
$$ LANGUAGE sql;