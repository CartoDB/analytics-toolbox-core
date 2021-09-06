----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._TOCHILDREN
(quadint BIGINT, resolution INT)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import to_children
    
    if quadint is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return str(to_children(quadint, resolution))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.TOCHILDREN
(BIGINT, INT)
-- (quadint, resolution)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@quadkey._TOCHILDREN($1, $2))
$$ LANGUAGE sql;