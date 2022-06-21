----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_RESOLUTION`
(quadbin INT64)
RETURNS INT64
AS ((
    SELECT quadbin >> 58
));