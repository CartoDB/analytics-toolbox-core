----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_FROMGEOGPOINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    QUADBIN_FROMLONGLAT(ST_X(point), ST_Y(point), resolution)
$$;