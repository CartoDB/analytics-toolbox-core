----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_to_geojson
    import json

    if quadbin is None:
        raise Exception('NULL argument passed to UDF')

    geojson = quadbin_to_geojson(quadbin)['geometry']
    return json.dumps(geojson)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_BOUNDARY
(BIGINT)
-- (quadbin)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.__QUADBIN_BOUNDARY($1)
$$ LANGUAGE sql;