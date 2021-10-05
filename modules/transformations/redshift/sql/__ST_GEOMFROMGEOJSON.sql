----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__GEOJSONTOWKT
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    import geojson
    
    def get_ring(coords):
        str_return = '('
        for p in coords:
            str_return += str(p[0]) + ' ' + str(p[1]) + ', '
        return str_return[:-1] + ')'

    if geom is None:
        return None

    geojson_str = geojson.loads(geom)
    geojson_type = geojson_str.type
    
    coords = []
    if geojson_type == 'GeometryCollection':
        coords = list(geojson.utils.coords(geojson_str.geometries))
    else:
        coords = list(geojson.utils.coords(geojson_str))

    if geojson_type == 'Point':
        return 'POINT (' + str(coords[0][0]) + ' ' + str(coords[0][1]) + ')'
    
    elif geojson_type == 'LineString':
        return 'LINESTRING' + get_ring(coords)

    elif geojson_type == 'Polygon':
        str_return = 'POLYGON ( '
        for ring in coords:
            str_return += get_ring(coords) + ','
        return str_return[:-1] + ')'

    else:
        raise Exception(geojson_type + ' not supported')

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON
(VARCHAR(MAX))
-- (geom)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@transformations.__GEOJSONTOWKT($1))
$$ LANGUAGE sql;