----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_TOGEOGPOINT`(quadint INT64)
RETURNS GEOGRAPHY AS (
  `@@BQ_PREFIX@@carto.QUADINT_CENTER`(quadint)
);