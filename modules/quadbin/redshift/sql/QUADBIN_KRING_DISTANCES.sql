----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import kring_distances
    import json

    if origin is None or origin <= 0:
        raise Exception('Invalid input origin')

    if size is None or size < 0:
        raise Exception('Invalid input size')

    return json.dumps(kring_distances(origin, size))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_KRING_DISTANCES
(BIGINT, INT)
-- (origin, size)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@carto.__QUADBIN_KRING_DISTANCES($1, $2))
$$ LANGUAGE sql;