----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__CENTROID
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
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

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.ST_CENTROID
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@carto.__CENTROID(ST_ASGEOJSON($1)::VARCHAR(MAX)))
$$ LANGUAGE sql;