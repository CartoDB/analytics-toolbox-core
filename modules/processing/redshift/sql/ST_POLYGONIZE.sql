----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.ST_POLYGONIZE
(GEOMETRY)
-- (lines)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_MAKEPOLYGON($1)
$$ LANGUAGE sql;