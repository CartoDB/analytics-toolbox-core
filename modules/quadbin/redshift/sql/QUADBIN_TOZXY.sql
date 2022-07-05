----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_TOZXY_INTERNAL
(quadbin BIGINT)
RETURNS VARCHAR
IMMUTABLE
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
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@carto.__QUADBIN_TOZXY_INTERNAL($1))
$$ LANGUAGE sql;