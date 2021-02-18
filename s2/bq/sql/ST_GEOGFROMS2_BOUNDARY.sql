-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ST_GEOGFROMKEY_BOUNDARY`
    (key STRING)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.GEOJSONBOUNDARY_FROMKEY(key))
);