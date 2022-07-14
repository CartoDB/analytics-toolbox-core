----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import to_children
    import json

    if quadbin is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return json.dumps(to_children(quadbin, resolution))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN
(BIGINT, INT)
-- (quadbin, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@carto.__QUADBIN_TOCHILDREN($1, $2))
$$ LANGUAGE sql;