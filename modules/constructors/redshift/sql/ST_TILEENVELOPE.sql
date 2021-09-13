----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_TILEENVELOPE
(INT, INT, INT)
-- (zoomLevel, xTile, yTiel)
RETURNS VARCHAR
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@quadkey.ST_BOUNDARY(@@RS_PREFIX@@quadkey.QUADINT_FROMZXY($1, $2, $3))
$$ LANGUAGE sql;