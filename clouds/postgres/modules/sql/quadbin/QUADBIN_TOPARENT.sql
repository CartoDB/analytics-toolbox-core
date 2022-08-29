----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_TOPARENT(
  quadbin BIGINT,
  resolution INT
)
RETURNS BIGINT
 AS
$BODY$
  SELECT CASE
  WHEN resolution < 0 OR resolution > ((quadbin >> 52) & 31)
  THEN @@PG_SCHEMA@@.__CARTO_ERROR('Invalid resolution')::BIGINT
  ELSE
    (quadbin & ~(31::BIGINT << 52)) | (resolution::BIGINT << 52) | (4503599627370495 >> (resolution << 1))
  END;
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
