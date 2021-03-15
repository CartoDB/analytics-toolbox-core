-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._TOPARENT
    (quadint STRING, resolution DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@

    if(!QUADINT || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return toParent(QUADINT, RESOLUTION).toString(); 
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOPARENT
    (quadint BIGINT, resolution INT)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._TOPARENT(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;