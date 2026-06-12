----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_RESOLUTION`
(quadbin INT64)
RETURNS INT64
AS ((
    SELECT (quadbin >> 52) & 0x1F
));
