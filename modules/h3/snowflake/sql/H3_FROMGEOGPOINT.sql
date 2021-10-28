----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION H3_FROMGEOGPOINT
(geog GEOGRAPHY, resolution INT)
RETURNS STRING
AS $$
    IFF(ST_NPOINTS(geog) = 1, 
        H3_FROMLONGLAT(ST_X(GEOG), ST_Y(GEOG), CAST(RESOLUTION AS DOUBLE)),
        null)
$$;