----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@processing.ST_VORONOIPOLYGONS`
(points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>)
RETURNS ARRAY<GEOGRAPHY>
AS (
    `@@BQ_PREFIX@@processing.__VORONOIGENERIC`(points, bbox, 'poly')   
);