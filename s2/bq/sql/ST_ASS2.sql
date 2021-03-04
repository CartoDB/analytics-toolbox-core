-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.S2_FROMLONGLAT`
    (longitude FLOAT64, latitude FLOAT64, resolution NUMERIC)
AS (
    (SELECT STRING_AGG(FORMAT('%02x', CAST(`@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.ID_FROMLONGLAT(longitude, latitude, resolution) AS INT64) >> (byte * 8) & 0xff), '' ORDER BY byte DESC)
    FROM UNNEST(GENERATE_ARRAY(0, 7)) AS byte)
);

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ST_ASS2`
    (point GEOGRAPHY, resolution NUMERIC)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.S2_FROMLONGLAT(ST_X(point), ST_Y(point), resolution)
);
