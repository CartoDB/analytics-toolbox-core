----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_ASH3
(geog GEOGRAPHY, resolution INT)
RETURNS STRING
AS $$
    IFF(ST_NPOINTS(geog) = 1, 
        LONGLAT_ASH3(ST_X(GEOG), ST_Y(GEOG), CAST(RESOLUTION AS DOUBLE)),
        null)
$$;