----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _S2_IDFROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (LATITUDE == null || LONGITUDE == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const key = s2Lib.latLngToKey(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    return s2Lib.keyToId(key);
$$;

CREATE OR REPLACE SECURE FUNCTION S2_IDFROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(_S2_IDFROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;