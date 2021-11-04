----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION H3_FROMGEOGPOINT
(geog GEOGRAPHY, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
<<<<<<< HEAD:modules/h3/snowflake/sql/H3_FROMGEOGPOINT.sql
    IFF(ST_NPOINTS(geog) = 1, 
        H3_FROMLONGLAT(ST_X(GEOG), ST_Y(GEOG), CAST(RESOLUTION AS DOUBLE)),
=======
    IFF(ST_NPOINTS(geog) = 1,
        @@SF_PREFIX@@h3.LONGLAT_ASH3(ST_X(GEOG), ST_Y(GEOG), CAST(RESOLUTION AS DOUBLE)),
>>>>>>> master:modules/h3/snowflake/sql/ST_ASH3.sql
        null)
$$;