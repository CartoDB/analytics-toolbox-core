----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_FROMLONGLAT
(longitude DOUBLE PRECISION, latitude DOUBLE PRECISION, resolution INTEGER)
RETURNS VARCHAR(16)
AS $$
    if (longitude == null || latitude == null || resolution == null) {
        return null;
    }

    @@PG_LIBRARY_H3_FROMLONGLAT@@

    return h3FromlonglatLib.geoToH3(latitude, longitude, resolution);
$$ LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
