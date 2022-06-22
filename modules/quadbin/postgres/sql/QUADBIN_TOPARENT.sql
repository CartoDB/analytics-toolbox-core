----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_TOPARENT(
  quadbin BIGINT,
  resolution INT
)
RETURNS BIGINT
 AS
$BODY$
  SELECT (quadbin & ~(31::BIGINT << 52)) | (resolution::BIGINT << 52) | (4503599627370495 >> (resolution << 1));
$BODY$
  LANGUAGE SQL;
