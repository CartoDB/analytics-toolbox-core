----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_TILEENVELOPE
(zoomLevel INT, xTile INT, yTile INT)
RETURNS GEOGRAPHY
AS $$
    QUADINT_BOUNDARY(QUADINT_FROMZXY(ZOOMLEVEL, XTILE, YTILE))
$$;