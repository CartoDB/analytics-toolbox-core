---------------------------------
-- Copyright (C) 2021-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    IFF(longitude IS NOT NULL AND latitude IS NOT NULL AND resolution >= 0 AND resolution <= 15,
	H3_LATLNG_TO_CELL_STRING(latitude, longitude, resolution),
        NULL)
$$;
