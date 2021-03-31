-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._HEXRING(index_lower DOUBLE, index_upper DOUBLE, distance DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (INDEX_LOWER == null || INDEX_UPPER == null || DISTANCE == null || DISTANCE < 0)
        return [];
    const h3IndexInput = [Number(INDEX_LOWER), Number(INDEX_UPPER)];
    if (!h3.h3IsValid(h3IndexInput))
        return [];

    try {
        return h3.hexRing(h3IndexInput, parseInt(DISTANCE)).map(h => '0x' + h);
    } catch (error) {
        return [];
    }
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.HEXRING(index BIGINT, distance INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._HEXRING(
        CAST(BITAND(INDEX, 4294967295) AS DOUBLE), 
        CAST(BITSHIFTRIGHT(INDEX, 32) AS DOUBLE),
        CAST(DISTANCE AS DOUBLE))
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.HEXRING(index STRING, distance INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.HEXRING(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(INDEX), DISTANCE)
$$;