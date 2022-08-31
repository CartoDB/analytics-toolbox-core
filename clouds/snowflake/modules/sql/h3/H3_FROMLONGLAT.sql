----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        return null;
    }

    @@SF_LIBRARY_H3_FROMLONGLAT@@

    const index = h3FromlonglatLib.geoToH3(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return index;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._H3_FROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE))
$$;