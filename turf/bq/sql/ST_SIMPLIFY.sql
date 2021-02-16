-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TURF@@.ST_SIMPLIFY`
    (geojson GEOGRAPHY, tolerance NUMERIC)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TURF@@.SIMPLIFY(ST_ASGEOJSON(geojson), STRUCT(tolerance as tolerance, true as highQuality)))
);
