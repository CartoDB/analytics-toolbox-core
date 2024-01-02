----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__CENTERMEAN
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.transformations import center_mean, PRECISION, wkt_from_geojson
    import geojson
    import json

    if geom is None:
        return None
    
    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)
    geojson_str = str(center_mean(geojson_geom))
    
    return wkt_from_geojson(geojson_str)

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_CENTERMEAN
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$

    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__CENTERMEAN(ST_ASGEOJSON($1)::VARCHAR(MAX)), 4326)
    
$$ LANGUAGE sql;
