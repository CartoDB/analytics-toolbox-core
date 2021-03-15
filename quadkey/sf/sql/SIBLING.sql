-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._SIBLING
    (quadint STRING, direction STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@

    if(!QUADINT || !DIRECTION)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return sibling(QUADINT, DIRECTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.SIBLING
    (quadint BIGINT, direction STRING)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._SIBLING(CAST(QUADINT AS STRING),DIRECTION) AS BIGINT)
$$;