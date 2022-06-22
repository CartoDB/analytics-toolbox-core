----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_INT_TOSTRING(
  quadbin BIGINT
)
RETURNS TEXT
 AS
$BODY$
  SELECT to_hex(quadbin);
$BODY$
  LANGUAGE SQL;
