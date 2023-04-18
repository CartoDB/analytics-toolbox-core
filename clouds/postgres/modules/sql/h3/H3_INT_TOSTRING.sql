----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_INT_TOSTRING(
    h3int BIGINT
)
RETURNS VARCHAR(16)
AS
$BODY$
    SELECT TO_HEX(h3int)
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
