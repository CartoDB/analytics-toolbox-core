----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@h3.ST_ASH3
(GEOMETRY, INT)
-- (point, resolution)
RETURNS BIGINT
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@h3.LONGLAT_ASH3(ST_X($1), ST_Y($1), $2)
$$ LANGUAGE sql;
