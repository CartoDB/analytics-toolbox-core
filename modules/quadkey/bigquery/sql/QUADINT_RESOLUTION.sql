----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_RESOLUTION`
  (quadint INT64)
RETURNS INT64
AS (`@@BQ_PREFIX@@QUADINT_TOZXY`(quadint).z);
