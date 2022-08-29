----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_CENTER
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import cell_to_point

    if quadbin is None:
        return None

    (x,y) = cell_to_point(quadbin)
    return 'POINT ({} {})'.format(x,y)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_CENTER
(BIGINT)
-- (quadbin)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__QUADBIN_CENTER($1), 4326)
$$ LANGUAGE sql;
