----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.__POLYFILL_FROMGEOJSON
(geojson VARCHAR(MAX), resolution INT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import geojson_to_quadints
    import json

    if geojson is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    pol = json.loads(geojson)
    quadints = []
    if pol['type'] == 'GeometryCollection':
        for geom in pol['geometries']:
            quadints += geojson_to_quadints(
                geom, {'min_zoom': resolution, 'max_zoom': resolution}
            )
        quadints = list(set(quadints))
    else:
        quadints = geojson_to_quadints(
            pol, {'min_zoom': resolution, 'max_zoom': resolution}
        )

    return str(quadints)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL
(GEOMETRY, INT)
-- (geo, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@quadkey.__POLYFILL_FROMGEOJSON(ST_ASGEOJSON($1)::VARCHAR(MAX), $2))
$$ LANGUAGE sql;