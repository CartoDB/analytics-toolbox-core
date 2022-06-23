----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_TOPARENT
(BIGINT, INT)
-- (quadbin, resolution)
RETURNS BIGINT
STABLE
AS $$
  SELECT CASE
  WHEN $2 < 0 OR $2 > (($1 >> 52) & 31)
  THEN CAST(@@RS_PREFIX@@carto.__QUADBIN_RAISE_EXCEPTION('Invalid resolution') AS BIGINT)
  ELSE
    ($1 & ~(CAST(31 AS BIGINT) << 52)) | (CAST($2 AS BIGINT) << 52) | (4503599627370495 >> ($2 << 1))
  END
$$ LANGUAGE sql;