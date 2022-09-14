----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_VORONOIPOLYGONS`
(points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>)
RETURNS ARRAY<GEOGRAPHY>
AS (
    `@@BQ_DATASET@@.__VORONOIGENERIC`(points, bbox, 'poly')   
);