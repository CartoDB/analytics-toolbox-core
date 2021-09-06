----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._KRING
(quadint BIGINT, distance INT)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import kring
    
    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    if distance is None:
        distance = 1

    return str(kring(quadint, distance))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.KRING
(BIGINT, INT)
-- (quadint, distance)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@quadkey._KRING($1, $2))
$$ LANGUAGE sql;
