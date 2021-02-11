-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_ASQUADINT`
    (point GEOGRAPHY, resolution NUMERIC) 
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.QUADINT_FROM_LOCATION(ST_Y(point),ST_X(point),resolution)
);