----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__CENTERMEDIAN
(geom VARCHAR(MAX), n_iter INT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.transformations import center_median, PRECISION, wkt_from_geojson
    import geojson
    import json
    
    if geom is None or n_iter is None:
        return None

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)
    geojson_str = str(center_median(geojson_geom, n_iter))
    
    return wkt_from_geojson(geojson_str)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_CENTERMEDIAN
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__CENTERMEDIAN(ST_ASGEOJSON($1)::VARCHAR(MAX), 100))
$$ LANGUAGE sql;
