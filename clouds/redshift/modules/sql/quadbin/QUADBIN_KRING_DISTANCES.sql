----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import k_ring_distances
    import json

    if origin is None or origin <= 0:
        raise Exception('Invalid input origin')

    if size is None or size < 0:
        raise Exception('Invalid input size')

    return json.dumps(k_ring_distances(origin, size))
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_KRING_DISTANCES
(BIGINT, INT)
-- (origin, size)
RETURNS SUPER
STABLE
AS $$
    SELECT JSON_PARSE(@@RS_SCHEMA@@.__QUADBIN_KRING_DISTANCES($1, $2))
$$ LANGUAGE SQL;
