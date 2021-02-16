-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.S2_FROMGEO`
    (latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
AS (
    (SELECT STRING_AGG(FORMAT('%02x', CAST(`@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.ID_FROMLATLNG(latitude, longitude, resolution) AS INT64) >> (byte * 8) & 0xff), '' ORDER BY byte DESC)
    FROM UNNEST(GENERATE_ARRAY(0, 7)) AS byte)
);

