-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TURF@@.ST_BUFFER`
    (geojson GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TURF@@.BUFFER(ST_ASGEOJSON(geojson),radius,STRUCT(units,steps)))
);