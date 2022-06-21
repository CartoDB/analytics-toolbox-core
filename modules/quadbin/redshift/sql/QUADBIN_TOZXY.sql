----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS VARCHAR
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_to_zxy
    import json
    
    if quadbin is None:
        raise Exception('NULL argument passed to UDF')

    return json.dumps(quadbin_to_zxy(quadbin))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_TOZXY
(BIGINT)
-- (quadbin)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@carto.__QUADBIN_TOZXY($1))
$$ LANGUAGE sql;