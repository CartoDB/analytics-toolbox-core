----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_RESOLUTION`
  (quadint INT64)
RETURNS INT64
AS (quadint & 0x1F);