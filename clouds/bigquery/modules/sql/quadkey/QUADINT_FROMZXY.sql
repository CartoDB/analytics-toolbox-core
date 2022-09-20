----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_FROMZXY`
(z INT64, x INT64, y INT64)
RETURNS INT64
AS ((
    (z & 0x1F) | (x << 5) | (y << (z + 5))
));
