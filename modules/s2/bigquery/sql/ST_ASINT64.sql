----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ST_ASINT64`
(point GEOGRAPHY, resolution INT64)
RETURNS INT64
AS ((
    `@@BQ_PREFIX@@s2.LONGLAT_ASINT64`(ST_X(point), ST_Y(point), resolution)
));