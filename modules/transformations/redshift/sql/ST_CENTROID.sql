----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__CENTROID
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import centroid, PRECISION
    import geojson
    import json
    
    if geom is None:
        return None

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)

    return str(centroid(geojson_geom))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_CENTROID
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__CENTROID(ST_ASGEOJSON($1)::VARCHAR(MAX)))
$$ LANGUAGE sql;