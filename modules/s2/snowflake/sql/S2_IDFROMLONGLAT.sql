----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __S2_IDFROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (LATITUDE == null || LONGITUDE == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    const key = s2Lib.latLngToKey(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return s2Lib.keyToId(key);
$$;

CREATE OR REPLACE SECURE FUNCTION S2_IDFROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(__S2_IDFROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;