----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_FROMGEOGPOINT
(point GEOGRAPHY, resolution INT)
RETURNS INT
AS $$
    QUADBIN_FROMLONGLAT(ST_X(point), ST_Y(point), resolution)
$$;