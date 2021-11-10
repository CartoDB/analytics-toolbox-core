----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADINT_FROMGEOGPOINT
(GEOMETRY, INT)
-- (point, resolution)
RETURNS BIGINT
STABLE
AS $$
    SELECT @@RS_PREFIX@@quadkey.QUADINT_FROMLONGLAT(ST_X($1), ST_Y($1), $2)
$$ LANGUAGE sql;