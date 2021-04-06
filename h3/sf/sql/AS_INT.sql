-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_FROMINT(index STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    if (INDEX == null)
    {
        return null;
    }
    return BigInt(INDEX).toString(16);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMINT(index BIGINT)
    RETURNS STRING
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_FROMINT(CAST(INDEX AS STRING))
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_ASINT(index STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    if (INDEX == null)
    {
        return null;
    }
    return BigInt('0x' + INDEX).toString(10);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_ASINT(index STRING)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_ASINT(INDEX) AS BIGINT)
$$;