----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_RESOLUTION`
  (quadint INT64)
RETURNS INT64
AS (`@@BQ_DATASET@@.QUADINT_TOZXY`(quadint).z);
