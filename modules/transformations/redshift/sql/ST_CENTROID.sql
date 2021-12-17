----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__CENTROID
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import centroid, PRECISION, wkt_from_geojson
    import geojson
    import json
    
    if geom is None:
        return None

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)
    geojson_str = str(centroid(geojson_geom))
    
    return wkt_from_geojson(geojson_str)

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.ST_CENTROID
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@carto.__CENTROID(ST_ASGEOJSON($1)::VARCHAR(MAX)))
$$ LANGUAGE sql;