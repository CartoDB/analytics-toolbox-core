----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._S2_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (LATITUDE == null || LONGITUDE == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_S2@@

    const key = s2Lib.latLngToKey(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return s2Lib.keyToId(key);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.S2_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_SCHEMA@@._S2_FROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;
