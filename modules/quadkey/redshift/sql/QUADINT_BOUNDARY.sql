----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADINT_BOUNDARY
(quadint BIGINT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadint_to_geojson
    import json

    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    geojson = quadint_to_geojson(quadint)['geometry']
    return json.dumps(geojson)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADINT_BOUNDARY
(BIGINT)
-- (quadint)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.__QUADINT_BOUNDARY($1)
$$ LANGUAGE sql;