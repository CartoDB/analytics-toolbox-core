----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.ST_ASQUADINT
(GEOMETRY, INT)
-- (point, resolution)
RETURNS INT
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASQUADINT(ST_X($1), ST_Y($1), $2)
$$ language sql;

