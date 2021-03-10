-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.SIBLING
    (quadint DOUBLE, direction STRING)
    RETURNS DOUBLE
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@

    if(QUADINT == null || !DIRECTION)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return sibling(QUADINT, DIRECTION);  
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.SIBLING
    (quadint INT, direction STRING)
    RETURNS INT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.SIBLING(CAST(QUADINT AS DOUBLE),DIRECTION) AS INT)
$$;