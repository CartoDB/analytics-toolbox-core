----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_POLYFILL
(geojson VARCHAR(MAX), resolution INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import geojson_to_quadbins
    import json

    if geojson is None or resolution is None:
        return None

    if resolution < 0 or resolution > 26:
        raise Exception('Invalid resolution, should be between 0 and 26')

    pol = json.loads(geojson)
    quadbins = []
    if pol['type'] == 'GeometryCollection':
        for geom in pol['geometries']:
            quadbins += geojson_to_quadbins(
                geom, {'min_zoom': resolution, 'max_zoom': resolution}
            )
        quadbins = list(set(quadbins))
    else:
        quadbins = geojson_to_quadbins(
            pol, {'min_zoom': resolution, 'max_zoom': resolution}
        )

    return json.dumps(quadbins)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_POLYFILL
(GEOMETRY, INT)
-- (geo, resolution)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT CASE ST_SRID($1)
        WHEN 0 THEN json_parse(@@RS_PREFIX@@carto.__QUADBIN_POLYFILL(ST_ASGEOJSON(ST_SetSRID($1, 4326))::VARCHAR(MAX), $2))
        ELSE json_parse(@@RS_PREFIX@@carto.__QUADBIN_POLYFILL(ST_ASGEOJSON(ST_TRANSFORM($1, 4326))::VARCHAR(MAX), $2))
    END$$ LANGUAGE sql;