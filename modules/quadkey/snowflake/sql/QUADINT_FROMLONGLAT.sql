----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADINT_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.quadintFromLocation(LONGITUDE, LATITUDE, RESOLUTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(_QUADINT_FROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;