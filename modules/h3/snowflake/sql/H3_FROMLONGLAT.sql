----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _H3_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        return null;
    }

    @@SF_LIBRARY_LONGLAT_ASH3@@

    const index = h3Lib.geoToH3(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return index;
$$;

CREATE OR REPLACE SECURE FUNCTION H3_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    _H3_FROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE))
$$;