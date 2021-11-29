----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.QUADINT_FROMGEOGPOINT`
(point GEOGRAPHY, resolution INT64)
RETURNS INT64
AS (
    `@@BQ_PREFIX@@quadkey.QUADINT_FROMLONGLAT`(ST_X(point), ST_Y(point), resolution)
);