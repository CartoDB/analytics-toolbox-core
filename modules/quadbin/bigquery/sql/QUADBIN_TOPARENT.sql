----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_TOPARENT`
(quadbin INT64, resolution INT64)
RETURNS INT64
AS ((
    SELECT (quadbin & ~(31 << 58) | (resolution << 58)) & (((1 << (5 + resolution * 2)) - 1) << (58 - resolution * 2))
));