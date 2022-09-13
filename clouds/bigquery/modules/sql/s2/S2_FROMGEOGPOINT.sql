----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_FROMGEOGPOINT`
(point GEOGRAPHY, resolution INT64)
RETURNS INT64
AS (
    `@@BQ_DATASET@@.S2_FROMLONGLAT`(ST_X(point), ST_Y(point), resolution)
);