----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_STRING_TOINT(
    h3 VARCHAR(16)
)
RETURNS BIGINT
AS
$BODY$
DECLARE
   result  BIGINT;
BEGIN
    EXECUTE 'SELECT x''' || h3 || '''::BIGINT' INTO result;
    RETURN result;
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
