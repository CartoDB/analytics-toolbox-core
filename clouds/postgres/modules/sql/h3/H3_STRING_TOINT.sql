----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_STRING_TOINT(
    h3 VARCHAR(16)
)
RETURNS BIGINT
AS $$
DECLARE
   result  BIGINT;
BEGIN
    EXECUTE 'SELECT x''' || h3 || '''::BIGINT' INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
