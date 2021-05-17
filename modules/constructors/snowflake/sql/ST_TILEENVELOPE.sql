----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@constructors.ST_TILEENVELOPE
(zoomLevel INT, xTile INT, yTile INT)
RETURNS GEOGRAPHY
AS $$
    @@SF_PREFIX@@quadkey.ST_BOUNDARY(@@SF_PREFIX@@quadkey.QUADINT_FROMZXY(ZOOMLEVEL, XTILE, YTILE))
$$;