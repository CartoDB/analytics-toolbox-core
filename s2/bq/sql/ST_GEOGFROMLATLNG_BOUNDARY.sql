-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ST_GEOGFROMLATLNG_BOUNDARY`
    (latitude FLOAT64, longitude FLOAT64, level NUMERIC)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.CORNERLATLNGS_FROMLATLNG(latitude, longitude, level))
);