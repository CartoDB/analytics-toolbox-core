-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ST_ASS2`
    (point GEOGRAPHY, resolution NUMERIC)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.S2_FROMGEO(ST_Y(point),ST_X(point),resolution)
);
