----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `%BQ_PROJECT%.%BQ_DATASET%.ST_ASH3`(geog GEOGRAPHY, resolution INT64)
    RETURNS STRING
AS
(
    `%BQ_PROJECT%.%BQ_DATASET%.LONGLAT_ASH3`(SAFE.ST_X(geog), SAFE.ST_Y(geog), resolution)
);
