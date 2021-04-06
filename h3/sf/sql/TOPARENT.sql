-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._TOPARENT(index STRING, resolution DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX)
        return null;
        
    if (!h3.h3IsValid(INDEX))
        return null;

    return h3.h3ToParent(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.TOPARENT(index STRING, resolution INT)
    RETURNS STRING
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._TOPARENT(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;
