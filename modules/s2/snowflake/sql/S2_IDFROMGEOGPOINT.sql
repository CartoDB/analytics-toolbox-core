----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION S2_IDFROMGEOGPOINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT
AS $$
    S2_IDFROMLONGLAT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;