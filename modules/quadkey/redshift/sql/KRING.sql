----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._KRING
(origin BIGINT, size INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import kring

    if origin is None or origin <= 0:
        raise Exception('Invalid input origin')

    if size is None or size < 0:
        raise Exception('Invalid input size')

    return str(kring(origin, size))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.KRING
(BIGINT, INT)
-- (origin, size)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@quadkey._KRING($1, $2))
$$ LANGUAGE sql;