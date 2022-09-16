----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_TILEENVELOPE`
(zoomLevel INT64, xTile INT64, yTile INT64)
RETURNS GEOGRAPHY
AS (
    `@@BQ_DATASET@@.QUADINT_BOUNDARY`(
        `@@BQ_DATASET@@.QUADINT_FROMZXY`(
            zoomlevel, xtile, ytile
        )
    )
);
