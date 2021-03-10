-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.LONGLAT_ASQUADINT
    (longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
    RETURNS DOUBLE
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@
    
    if(LONGITUDE == null || LATITUDE == null || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return quadintFromLocation(LONGITUDE, LATITUDE, RESOLUTION);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.LONGLAT_ASQUADINT(longitude DOUBLE, latitude DOUBLE, resolution INT)
    RETURNS INT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.LONGLAT_ASQUADINT(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS INT)
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.ST_ASQUADINT
    (point GEOGRAPHY, resolution INT)
    RETURNS INT 
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.LONGLAT_ASQUADINT(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;

