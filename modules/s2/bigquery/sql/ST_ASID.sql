----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ST_ASID`
(point GEOGRAPHY, resolution INT64)
AS (
    `@@BQ_PREFIX@@s2.LONGLAT_ASID`(ST_X(point), ST_Y(point), resolution)
);
