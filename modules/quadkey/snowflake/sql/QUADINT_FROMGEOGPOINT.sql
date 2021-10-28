----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION QUADINT_FROMGEOGPOINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT 
AS $$
    QUADINT_FROMLONGLAT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;

