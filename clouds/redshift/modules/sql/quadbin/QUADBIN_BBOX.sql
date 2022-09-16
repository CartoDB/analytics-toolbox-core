----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_BBOX
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import cell_to_bounding_box
    import json

    if quadbin is None:
        return None

    return json.dumps(cell_to_bounding_box(quadbin))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_BBOX
(BIGINT)
-- (quadbin)
RETURNS SUPER
STABLE
AS $$
    SELECT JSON_PARSE(@@RS_SCHEMA@@.__QUADBIN_BBOX($1))
$$ LANGUAGE sql;
