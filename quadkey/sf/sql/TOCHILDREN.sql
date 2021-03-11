-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOCHILDREN
    (quadint DOUBLE, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@

    if(QUADINT == null || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return children(QUADINT, RESOLUTION);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOCHILDREN
    (quadint INT, resolution INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOCHILDREN(CAST(QUADINT AS DOUBLE), CAST(RESOLUTION AS DOUBLE))
$$;