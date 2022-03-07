----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.ST_TILEENVELOPE
(INT, INT, INT)
-- (zoomLevel, xTile, yTiel)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT @@RS_PREFIX@@carto.QUADINT_BOUNDARY(@@RS_PREFIX@@carto.QUADINT_FROMZXY($1, $2, $3))
$$ LANGUAGE sql;