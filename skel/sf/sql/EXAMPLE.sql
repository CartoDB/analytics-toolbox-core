-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_SKEL@@._EXAMPLE_ADD
    (value DOUBLE)
    RETURNS DOUBLE
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    return skelExampleAdd(parseInt(VALUE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_SKEL@@.EXAMPLE_ADD
    (value INT)
    RETURNS INT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_SKEL@@._EXAMPLE_ADD(CAST(value AS DOUBLE)) AS INT)
$$;