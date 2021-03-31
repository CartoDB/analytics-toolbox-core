-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_ASHEX(index STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    if (INDEX == null)
    {
        return null;
    }
    return '0x' + BigInt(INDEX).toString(16);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_ASHEX(index BIGINT)
    RETURNS STRING
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_ASHEX(CAST(INDEX AS STRING))
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_FROMHEX(index STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    if (INDEX == null)
    {
        return null;
    }
    return BigInt(INDEX).toString(10);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(index STRING)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._H3_FROMHEX(INDEX) AS BIGINT)
$$;