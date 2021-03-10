-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.BBOX
    (quadint DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS
$$
    @@WASM_FILE_CONTENTS@@
    
    if(QUADINT == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.BBOX
    (quadint INT)
    RETURNS ARRAY
AS
$$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.BBOX(CAST(QUADINT AS DOUBLE))
$$;