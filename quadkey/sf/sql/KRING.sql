-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._KRING
    (quadint STRING, distance DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@
    
    if(!QUADINT)
    {
        throw new Error('NULL argument passed to UDF');
    }

    if(DISTANCE == null)
    {
        DISTANCE = 1;
    }
    let neighbors = kring(QUADINT, DISTANCE);
    return neighbors.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING
    (quadint BIGINT, distance INT)
    RETURNS ARRAY
AS $$
    SELECT ARRAY_AGG(CAST(VALUE AS BIGINT)) from lateral FLATTEN(input => @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._KRING(CAST(QUADINT AS STRING), CAST(DISTANCE AS DOUBLE)))
$$;