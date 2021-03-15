-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._TOCHILDREN
    (quadint STRING, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@

    if(!QUADINT || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    let quadints = toChildren(QUADINT, RESOLUTION);
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOCHILDREN
    (quadint BIGINT, resolution INT)
    RETURNS ARRAY
AS $$
    SELECT ARRAY_AGG(CAST(VALUE AS BIGINT)) from lateral FLATTEN(input => @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._TOCHILDREN(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE)))
$$;