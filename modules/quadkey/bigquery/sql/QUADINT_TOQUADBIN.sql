----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_TOQUADBIN`
(quadint INT64)
RETURNS INT64
AS ((
  `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(
    quadint & 0x1F,
    (quadint >> 5) & ((1 << (quadint & 0x1F)) - 1),
    (quadint >> (5 + (quadint & 0x1F)))
  )
));
