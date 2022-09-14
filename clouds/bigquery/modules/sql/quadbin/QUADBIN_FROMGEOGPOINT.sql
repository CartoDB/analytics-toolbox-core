----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_FROMGEOGPOINT`
(point GEOGRAPHY, resolution INT64)
RETURNS INT64
AS (
    `@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(ST_X(point), ST_Y(point), resolution)
);