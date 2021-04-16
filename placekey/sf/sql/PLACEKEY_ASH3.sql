-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@.PLACEKEY_ASH3(placekey STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if (!placekeyIsValid(PLACEKEY))  {
        return null;
    }
    return placekeyToH3(PLACEKEY);
$$;
