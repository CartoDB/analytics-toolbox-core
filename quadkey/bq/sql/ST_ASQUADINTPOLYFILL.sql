-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_ASQUADINTPOLYFILL`
    (geo GEOGRAPHY, resolution NUMERIC)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.POLYFILL_FROM_GEOJSON(ST_ASGEOJSON(geo),resolution)
);