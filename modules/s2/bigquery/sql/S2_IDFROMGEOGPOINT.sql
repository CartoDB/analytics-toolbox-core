----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.S2_IDFROMGEOGPOINT`
(point GEOGRAPHY, resolution INT64)
RETURNS INT64
AS (
    `@@BQ_PREFIX@@s2.S2_IDFROMLONGLAT`(ST_X(point), ST_Y(point), resolution)
);