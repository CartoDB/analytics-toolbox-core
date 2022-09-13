----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_MAKEENVELOPE
(FLOAT8, FLOAT8, FLOAT8, FLOAT8)
-- (xmin, ymin, xmax, ymax)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT('POLYGON((' || $1 || ' ' || $2 || ',' || $1 || ' ' || $4 || ',' || $3 || ' ' || $4 || ',' || $3 || ' ' || $2 || ',' || $1 || ' ' || $2 || '))')
$$ LANGUAGE SQL;
