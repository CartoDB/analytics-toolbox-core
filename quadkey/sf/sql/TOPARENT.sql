-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOPARENT
    (quadint DOUBLE, resolution DOUBLE)
    RETURNS DOUBLE
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@

    if(quadint == null || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return toParent(QUADINT, RESOLUTION);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOPARENT
    (quadint INT, resolution INT)
    RETURNS INT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.TOPARENT(CAST(QUADINT AS DOUBLE), CAST(RESOLUTION AS DOUBLE)) AS INT)
$$;