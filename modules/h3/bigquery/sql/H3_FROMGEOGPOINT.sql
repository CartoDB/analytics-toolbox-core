----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.H3_FROMGEOGPOINT`
(geog GEOGRAPHY, resolution INT64)
RETURNS STRING
AS (
    `@@BQ_PREFIX@@h3.H3_FROMLONGLAT`(SAFE.ST_X(geog), SAFE.ST_Y(geog), resolution)
);