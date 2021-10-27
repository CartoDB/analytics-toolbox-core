----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_ASID
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT
AS $$
    LONGLAT_ASID(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;