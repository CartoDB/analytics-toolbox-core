----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_TOPARENT`
(quadbin INT64, resolution INT64)
RETURNS INT64
AS ((
    IF(resolution < 0 OR resolution > ((quadbin >> 52) & 0x1F),
        ERROR('Invalid resolution'),
        (SELECT (quadbin & ~(0x1F << 52)) | (resolution << 52) | (0xFFFFFFFFFFFFF >> (resolution * 2)))
    )
));
