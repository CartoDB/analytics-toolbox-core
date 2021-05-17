----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ST_ASTOKEN`
(point GEOGRAPHY, resolution INT64)
RETURNS STRING
AS ((
    `@@BQ_PREFIX@@s2.LONGLAT_ASTOKEN`(ST_X(point), ST_Y(point), resolution)
));