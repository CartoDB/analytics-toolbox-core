-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._TOPARENT(index_lower DOUBLE, index_upper DOUBLE, resolution DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (INDEX_LOWER == null || INDEX_UPPER == null)
        return null;
    const h3IndexInput = [Number(INDEX_LOWER), Number(INDEX_UPPER)];
    if (!h3.h3IsValid(h3IndexInput))
        return null;
    return '0x' + h3.h3ToParent([Number(INDEX_LOWER), Number(INDEX_UPPER)], Number(RESOLUTION));
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOPARENT(index BIGINT, resolution INT)
    RETURNS BIGINT
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._TOPARENT(
        CAST(BITAND(INDEX, 4294967295) AS DOUBLE), 
        CAST(BITSHIFTRIGHT(INDEX, 32) AS DOUBLE), 
        CAST(RESOLUTION AS DOUBLE)))
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOPARENT(index STRING, resolution INT)
    RETURNS BIGINT
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOPARENT(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(INDEX), RESOLUTION)
$$;