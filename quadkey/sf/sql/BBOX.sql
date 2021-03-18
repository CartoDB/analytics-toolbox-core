-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._BBOX
    (quadint STRING)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS
$$
    @@LIBRARY_FILE_CONTENT@@
    
    if(!QUADINT)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.BBOX
    (quadint BIGINT)
    RETURNS ARRAY
AS
$$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._BBOX(CAST(QUADINT AS STRING))
$$;