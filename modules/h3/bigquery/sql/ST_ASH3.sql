----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.ST_ASH3`
(geog GEOGRAPHY, resolution INT64)
RETURNS STRING
AS (
    `@@BQ_PREFIX@@h3.LONGLAT_ASH3`(SAFE.ST_X(geog), SAFE.ST_Y(geog), resolution)
);