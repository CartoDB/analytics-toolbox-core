----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_ASID(
    point GEOMETRY,
    resolution INTEGER
)
RETURNS INT8
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@s2.LONGLAT_ASID(ST_X($1)::FLOAT, ST_Y($1)::FLOAT, $2)
$$ LANGUAGE sql;
