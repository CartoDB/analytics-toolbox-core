----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import cell_to_children
    import json

    if quadbin is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return json.dumps(cell_to_children(quadbin, resolution))
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_TOCHILDREN
(BIGINT, INT)
-- (quadbin, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT JSON_PARSE(@@RS_SCHEMA@@.__QUADBIN_TOCHILDREN($1, $2))
$$ LANGUAGE SQL;
