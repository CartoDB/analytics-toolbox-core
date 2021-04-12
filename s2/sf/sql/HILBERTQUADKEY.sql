-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._ID_FROMHILBERTQUADKEY
    (quadkey STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if(!QUADKEY)
    {
        throw new Error('NULL argument passed to UDF');
    }

    return S2.keyToId(QUADKEY);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.ID_FROMHILBERTQUADKEY
    (quadkey STRING)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._ID_FROMHILBERTQUADKEY(QUADKEY) AS BIGINT)
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._HILBERTQUADKEY_FROMID
    (id STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if(!ID)
    {
        throw new Error('NULL argument passed to UDF');
    }

    return S2.idToKey(ID);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.HILBERTQUADKEY_FROMID
    (id BIGINT)
    RETURNS STRING
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._HILBERTQUADKEY_FROMID(CAST(ID AS STRING))
$$;