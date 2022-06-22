----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_TOPARENT`
(quadbin INT64, resolution INT64)
RETURNS INT64
AS ((
    SELECT (quadbin & ~(0x1F << 52)) | (resolution << 52) | (0xFFFFFFFFFFFFF >> (resolution * 2))
));