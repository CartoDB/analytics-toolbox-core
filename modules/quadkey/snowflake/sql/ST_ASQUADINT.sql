----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.ST_ASQUADINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT 
AS $$
    @@SF_PREFIX@@quadkey.LONGLAT_ASQUADINT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;

