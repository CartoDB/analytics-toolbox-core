----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_KRING
(origin BIGINT, size INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import k_ring
    import json

    if origin is None or origin <= 0:
        raise Exception('Invalid input origin')

    if size is None or size < 0:
        raise Exception('Invalid input size')

    return json.dumps(k_ring(origin, size))
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_KRING
(BIGINT, INT)
-- (origin, size)
RETURNS SUPER
STABLE
AS $$
    SELECT JSON_PARSE(@@RS_SCHEMA@@.__QUADBIN_KRING($1, $2))
$$ LANGUAGE SQL;
