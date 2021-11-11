----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.S2_IDFROMGEOGPOINT
(point GEOMETRY, resolution INT4)
RETURNS INT8
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.S2_IDFROMLONGLAT(ST_X($1)::FLOAT8, ST_Y($1)::FLOAT8, $2)
$$ LANGUAGE sql;
