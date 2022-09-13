----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_POLYFILL
(geojson VARCHAR(MAX), resolution INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import geometry_to_cells
    import json

    if geojson is None or resolution is None:
        return None

    if resolution < 0 or resolution > 26:
        raise Exception('Invalid resolution, should be between 0 and 26')

    quadbins = geometry_to_cells(geojson, resolution)

    return json.dumps(quadbins)
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_POLYFILL
(GEOMETRY, INT)
-- (geo, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT CASE ST_SRID($1)
        WHEN 0 THEN JSON_PARSE(@@RS_SCHEMA@@.__QUADBIN_POLYFILL(ST_ASGEOJSON(ST_SETSRID($1, 4326))::VARCHAR(MAX), $2))
        ELSE JSON_PARSE(@@RS_SCHEMA@@.__QUADBIN_POLYFILL(ST_ASGEOJSON(ST_TRANSFORM($1, 4326))::VARCHAR(MAX), $2))
    END
$$ LANGUAGE SQL;
