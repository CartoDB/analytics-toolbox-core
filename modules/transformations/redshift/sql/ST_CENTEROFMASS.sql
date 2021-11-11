----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.ST_CENTEROFMASS
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.ST_CENTROID($1)
$$ LANGUAGE sql;