-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._LONGLAT_ASQUADINT
    (longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if(LONGITUDE == null || LATITUDE == null || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return quadintFromLocation(LONGITUDE, LATITUDE, RESOLUTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.LONGLAT_ASQUADINT(longitude DOUBLE, latitude DOUBLE, resolution INT)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._LONGLAT_ASQUADINT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.ST_ASQUADINT
    (point GEOGRAPHY, resolution INT)
    RETURNS BIGINT 
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.LONGLAT_ASQUADINT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;

