----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_BBOX
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import bbox
    import json
    
    if quadbin is None:
        raise Exception('NULL argument passed to UDF')

    return json.dumps(bbox(quadbin))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_BBOX
(BIGINT)
-- (quadbin)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@carto.__QUADBIN_BBOX($1))
$$ LANGUAGE sql;