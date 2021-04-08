-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._LONGLAT_ASID
    (longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if(LATITUDE == null || LONGITUDE == null || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return S2.latLngToId(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.LONGLAT_ASID
    (longitude DOUBLE, latitude DOUBLE, resolution INT)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._LONGLAT_ASID(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.ST_ASID
    (point GEOGRAPHY, resolution INT)
    RETURNS BIGINT
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.LONGLAT_ASID(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;
