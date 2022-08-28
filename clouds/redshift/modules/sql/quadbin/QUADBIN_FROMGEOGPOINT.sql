----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_FROMGEOGPOINT
(GEOMETRY, INT)
-- (point, resolution)
RETURNS BIGINT
STABLE
AS $$
    SELECT CASE ST_SRID($1)
        WHEN 0 THEN @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(ST_X(ST_SETSRID($1, 4326)), ST_Y(ST_SETSRID($1, 4326)), $2)
        ELSE @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(ST_X(ST_TRANSFORM($1, 4326)), ST_Y(ST_TRANSFORM($1, 4326)), $2)
    END
$$ LANGUAGE sql;