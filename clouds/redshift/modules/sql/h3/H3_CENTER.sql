----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__H3_CENTER
(h3 VARCHAR(16))
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.h3 import h3_cell_to_latlng

    if h3 is None:
        return None

    p = h3_cell_to_latlng(int(h3, base=16))
    return 'POINT ({} {})'.format(p.lng, p.lat)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.H3_CENTER
(VARCHAR(16))
-- (h3)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__H3_CENTER($1), 4326)
$$ LANGUAGE sql;
