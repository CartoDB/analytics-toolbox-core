----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_ASQUADINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT 
AS $$
    LONGLAT_ASQUADINT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;

