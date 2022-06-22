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
        return None

    geojson = quadbin_to_geojson(quadbin)['geometry']
    return json.dumps(geojson)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_BOUNDARY
(BIGINT)
-- (quadbin)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@carto.__QUADBIN_BOUNDARY($1), 4326)
$$ LANGUAGE sql;