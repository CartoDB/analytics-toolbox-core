----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.LONGLAT_ASTOKEN`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS STRING
AS ((
    `@@BQ_PREFIX@@s2.TOKEN_FROMINT64`(`@@BQ_PREFIX@@s2.LONGLAT_ASINT64`(longitude, latitude, resolution))
));