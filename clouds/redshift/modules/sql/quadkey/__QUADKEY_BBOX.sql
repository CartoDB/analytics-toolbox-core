----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADKEY_BBOX_INTERNAL
(quadkey VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.quadkey import bbox_quadkey

    if quadkey is None:
        raise Exception('NULL argument passed to UDF')

    return str(bbox_quadkey(quadkey))
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADKEY_BBOX
(VARCHAR(MAX))
-- (quadkey)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_SCHEMA@@.__QUADKEY_BBOX_INTERNAL($1))
$$ LANGUAGE SQL;
