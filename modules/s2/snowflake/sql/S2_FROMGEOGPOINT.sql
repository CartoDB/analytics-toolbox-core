----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION S2_FROMGEOGPOINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    S2_FROMLONGLAT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;