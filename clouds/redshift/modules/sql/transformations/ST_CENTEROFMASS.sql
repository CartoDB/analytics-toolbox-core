----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_CENTEROFMASS
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT @@RS_SCHEMA@@.ST_CENTROID($1)
$$ LANGUAGE sql;
