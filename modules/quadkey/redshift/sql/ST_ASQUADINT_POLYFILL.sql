----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._POLYFILL_FROMGEOJSON
(geojson VARCHAR(MAX), resolution INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import geojsonToQuadints
    import json

    if geojson is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    pol = json.loads(geojson)
    quadints = []
    if pol['type'] == 'GeometryCollection':
        for geom in pol['geometries']:
            quadints += geojsonToQuadints(
                geom, {'min_zoom': resolution, 'max_zoom': resolution}
            )
        quadints = list(set(quadints))
    else:
        quadints = geojsonToQuadints(
            pol, {'min_zoom': resolution, 'max_zoom': resolution}
        )

    return str(quadints)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL
(GEOMETRY, INT)
-- (geo, resolution)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@quadkey._POLYFILL_FROMGEOJSON(ST_ASGEOJSON($1)::VARCHAR(MAX), $2))
$$ LANGUAGE sql;