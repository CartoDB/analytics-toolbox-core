----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_POLYGONIZE
(GEOMETRY)
-- (lines)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_MAKEPOLYGON($1)
$$ LANGUAGE sql;
