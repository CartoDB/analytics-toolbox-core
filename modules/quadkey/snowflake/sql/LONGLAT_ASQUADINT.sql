----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._LONGLAT_ASQUADINT
(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if(LONGITUDE == null || LATITUDE == null || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return lib.quadintFromLocation(LONGITUDE, LATITUDE, RESOLUTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.LONGLAT_ASQUADINT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
AS $$
    CAST(@@SF_PREFIX@@quadkey._LONGLAT_ASQUADINT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;