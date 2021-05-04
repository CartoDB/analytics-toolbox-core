-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.ST_VORONOIPOLYGONS`
    (points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>)
    RETURNS ARRAY<GEOGRAPHY>
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_PROCESSING@@.__VORONOIGENERIC(points, bbox, 'poly')   
);

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.ST_VORONOILINES`
    (points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>)
    RETURNS ARRAY<GEOGRAPHY>
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_PROCESSING@@.__VORONOIGENERIC(points, bbox, 'lines')   
);