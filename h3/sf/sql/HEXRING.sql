-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._HEXRING(index STRING, distance DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX || DISTANCE == null || DISTANCE < 0)
        return [];
        
    if (!h3.h3IsValid(INDEX))
        return [];

    try {
        return h3.hexRing(INDEX, parseInt(DISTANCE));
    } catch (error) {
        return [];
    }
$$;
