-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_SQUELLETON@@._EXAMPLE_ADD
    (value DOUBLE)
    RETURNS DOUBLE
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    return squelletonExampleAdd(parseInt(VALUE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_SQUELLETON@@.EXAMPLE_ADD
    (value INT)
    RETURNS INT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_SQUELLETON@@._EXAMPLE_ADD(CAST(value AS DOUBLE)) AS INT)
$$;