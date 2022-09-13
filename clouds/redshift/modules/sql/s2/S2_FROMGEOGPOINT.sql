----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_FROMGEOGPOINT
(point GEOMETRY, resolution INT4)
RETURNS INT8
STABLE
AS $$
    SELECT @@RS_SCHEMA@@.S2_FROMLONGLAT(ST_X($1)::FLOAT8, ST_Y($1)::FLOAT8, $2)
$$ LANGUAGE SQL;
