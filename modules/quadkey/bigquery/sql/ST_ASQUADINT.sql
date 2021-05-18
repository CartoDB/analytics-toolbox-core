----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_ASQUADINT`
(point GEOGRAPHY, resolution INT64)
RETURNS INT64
AS (
    `@@BQ_PREFIX@@quadkey.LONGLAT_ASQUADINT`(ST_X(point), ST_Y(point), resolution)
);