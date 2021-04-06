-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._KRING(index STRING, distance DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX || DISTANCE == null || DISTANCE < 0)
        return [];
        
    if (!h3.h3IsValid(INDEX))
        return [];

    return h3.kRing(INDEX, parseInt(DISTANCE));
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.KRING(index STRING, distance INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._KRING(INDEX, CAST(DISTANCE AS DOUBLE))
$$;
