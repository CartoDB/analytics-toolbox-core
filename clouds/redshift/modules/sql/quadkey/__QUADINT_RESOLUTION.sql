----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADINT_RESOLUTION
(index BIGINT)
RETURNS BIGINT
STABLE
AS $$
    SELECT CAST($1 AS BIGINT) & CAST(31 AS BIGINT)
$$ LANGUAGE sql;