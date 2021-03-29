-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ISVALID(index_lower DOUBLE, index_upper DOUBLE)
    RETURNS BOOLEAN
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (INDEX_LOWER == null || INDEX_UPPER == null)
        return false;
    return h3.h3IsValid([Number(INDEX_LOWER), Number(INDEX_UPPER)]);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ISVALID(index BIGINT)
    RETURNS BOOLEAN
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ISVALID(
        CAST(BITAND(INDEX, 4294967295) AS DOUBLE), 
        CAST(BITSHIFTRIGHT(INDEX, 32) AS DOUBLE))
$$;