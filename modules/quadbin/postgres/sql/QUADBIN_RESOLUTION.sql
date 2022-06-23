----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_RESOLUTION(
  quadbin BIGINT
)
RETURNS INT
 AS
$BODY$
    SELECT ((quadbin >> 52) & 31)::INT;
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
