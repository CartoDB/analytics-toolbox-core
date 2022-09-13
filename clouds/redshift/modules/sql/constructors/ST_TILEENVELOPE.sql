----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_TILEENVELOPE
(INT, INT, INT)
-- (zoomLevel, xTile, yTile)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT @@RS_SCHEMA@@.QUADBIN_BOUNDARY(@@RS_SCHEMA@@.QUADBIN_FROMZXY($1, $2, $3))
$$ LANGUAGE SQL;
