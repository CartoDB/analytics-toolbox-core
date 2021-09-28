----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.ST_POLYGONIZE
(GEOMETRY)
-- (lines)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT ST_MAKEPOLYGON($1)
$$ LANGUAGE sql;