-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PLACEKEY@@.ST_ASPLACEKEY`
    (point GEOGRAPHY)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_PLACEKEY@@.PLACEKEY_FROMGEO(ST_Y(point),ST_X(point))
);