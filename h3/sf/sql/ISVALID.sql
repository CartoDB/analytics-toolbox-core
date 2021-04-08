-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ISVALID(index STRING)
    RETURNS BOOLEAN
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX)
        return false;

    return h3.h3IsValid(INDEX);
$$;
