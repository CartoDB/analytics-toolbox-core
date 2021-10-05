----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__CENTERMEAN
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import center_mean
    import geojson
    import json

    if geom is None:
        return None
    
    _geom = json.loads(geom)
    _geom['precision'] = 15
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)

    return str(center_mean(geojson_geom))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_CENTERMEAN
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__CENTERMEAN(ST_ASGEOJSON($1)::VARCHAR(MAX)))
$$ LANGUAGE sql;