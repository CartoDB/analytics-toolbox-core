----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADINT_POLYFILL
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

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADINT_POLYFILL
(GEOMETRY, INT)
-- (geo, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT CASE ST_SRID($1)
        WHEN 0 THEN json_parse(@@RS_PREFIX@@carto.__QUADINT_POLYFILL(ST_ASGEOJSON(ST_SetSRID($1, 4326))::VARCHAR(MAX), $2))
        ELSE json_parse(@@RS_PREFIX@@carto.__QUADINT_POLYFILL(ST_ASGEOJSON(ST_TRANSFORM($1, 4326))::VARCHAR(MAX), $2))
    END
$$ LANGUAGE sql;