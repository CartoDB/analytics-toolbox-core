--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------

-- The function returns a STRING for two main issues related with Snowflake limitations
-- 1. Snowflake has a native support of BigInt numbers, however, if the UDF
-- returns this data type the next Snowflake internal error is raised:
-- SQL execution internal error: Processing aborted due to error 300010:3321206824
-- 2. If the UDF returns the hex codification of the quadbin to be parsed in a SQL
-- higher level by using the _QUADBIN_STRING_TOINT UDF a non-correlated query can be produced.

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_KRING
(origin BIGINT, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    IFF(origin IS NULL OR size IS NULL,
        NULL,
        TO_ARRAY(PARSE_JSON(@@SF_SCHEMA@@._QUADBIN_KRING(TO_VARCHAR(ORIGIN, 'xxxxxxxxxxxxxxxx'), SIZE, false)))
    )
$$;
