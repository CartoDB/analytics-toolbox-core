-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._TOCHILDREN(index STRING, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX)
        return [];
        
    if (!h3.h3IsValid(INDEX))
        return [];

    return h3.h3ToChildren(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOCHILDREN(index STRING, resolution INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._TOCHILDREN(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;
