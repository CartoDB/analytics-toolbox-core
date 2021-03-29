-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_ASHEX(index BIGINT)
    RETURNS STRING
AS $$
    FORMAT("%x", INDEX)
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(index STRING)
    RETURNS BIGINT
AS $$
    TRY_CAST(CONCAT('0x', INDEX) AS BIGINT)
$$;