-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PLACEKEY@@.ST_GEOGFROMPLACEKEY_POINT`
    (placekey STRING)
AS (   
    ST_GEOGPOINT(
        CAST(split(`@@BQ_PROJECTID@@`.@@BQ_DATASET_PLACEKEY@@.LONGLAT_FROMPLACEKEY(placekey),",")[OFFSET (0)] AS FLOAT64),
        CAST(split(`@@BQ_PROJECTID@@`.@@BQ_DATASET_PLACEKEY@@.LONGLAT_FROMPLACEKEY(placekey),",")[OFFSET (1)] AS FLOAT64))
);
