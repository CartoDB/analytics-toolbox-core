----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADINT_FROMGEOGPOINT
(GEOMETRY, INT)
-- (point, resolution)
RETURNS BIGINT
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.QUADINT_FROMLONGLAT(ST_X(ST_SetSRID($1, 4326)), ST_Y(ST_SetSRID($1, 4326)), $2)
$$ LANGUAGE sql;