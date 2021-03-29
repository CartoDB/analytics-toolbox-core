-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.VERSION()
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    return '3.7.0.0';
$$;