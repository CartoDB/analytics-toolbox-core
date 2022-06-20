
----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_FROMZXY
(zxy VARCHAR(MAX))
-- (quadint)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadbin_from_zxy
    import json

    zxy = json.loads(zxy)

    return quadbin_from_zxy(zxy['z'], zxy['x'], zxy['y'])
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_FROMQUADINT
(BIGINT)
-- (quadint)
RETURNS BIGINT
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.__QUADBIN_FROMZXY(JSON_SERIALIZE(@@RS_PREFIX@@carto.QUADINT_TOZXY($1)))
$$ LANGUAGE sql;