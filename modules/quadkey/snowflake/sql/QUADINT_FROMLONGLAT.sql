----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADINT_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return quadkeyLib.quadintFromLocation(LONGITUDE, LATITUDE, RESOLUTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(__QUADINT_FROMLONGLAT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;