-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.ST_TILEENVELOPE`
    (zoomLevel INT64, xTile INT64, yTile INT64)
RETURNS GEOGRAPHY
OPTIONS (description="Returns the boundary polygon of a tile given its zoom level and its X and Y indices.")
AS (
    `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_BOUNDARY`(`@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.QUADINT_FROMZXY`(zoomLevel,xTile,yTile))
);