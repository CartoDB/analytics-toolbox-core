----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _LONGLAT_ASH3
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_LONGLAT_ASH3@@

    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        return null;
    }
    const index = h3Lib.geoToH3(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return index;
$$;

CREATE OR REPLACE SECURE FUNCTION LONGLAT_ASH3
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS STRING
AS $$
    _LONGLAT_ASH3(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE))
$$;