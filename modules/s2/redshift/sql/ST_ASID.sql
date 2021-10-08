----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_ASID
(point GEOMETRY, resolution INT4)
RETURNS INT8
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@s2.LONGLAT_ASID(ST_X($1)::FLOAT8, ST_Y($1)::FLOAT8, $2)
$$ LANGUAGE sql;
