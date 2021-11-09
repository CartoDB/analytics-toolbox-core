----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._LONGLAT_ASH3
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_LONGLAT_ASH3@@
        geoToH3 = h3Lib.geoToH3;
    }

    if (typeof(geoToH3) === "undefined") {
        setup();
    }
    
    const index = geoToH3(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return index;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.LONGLAT_ASH3
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._LONGLAT_ASH3(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE))
$$;