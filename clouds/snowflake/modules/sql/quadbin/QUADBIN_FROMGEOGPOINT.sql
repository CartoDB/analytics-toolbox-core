----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMGEOGPOINT
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    @@SF_SCHEMA@@.QUADBIN_FROMLONGLAT(ST_X(point), ST_Y(point), resolution)
$$;