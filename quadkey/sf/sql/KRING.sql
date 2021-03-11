-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING
    (quadint DOUBLE, distance DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@
    
    if(QUADINT == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    if(DISTANCE == null)
    {
        DISTANCE = 1;
    }

    return kring(QUADINT, DISTANCE);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING
    (quadint INT, distance INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING(CAST(QUADINT AS DOUBLE), CAST(DISTANCE AS DOUBLE))
$$;