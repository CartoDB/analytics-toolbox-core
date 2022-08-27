----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_INT_TOSTRING(
  quadbin BIGINT
)
RETURNS TEXT
 AS
$BODY$
  SELECT TO_HEX(quadbin);
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
