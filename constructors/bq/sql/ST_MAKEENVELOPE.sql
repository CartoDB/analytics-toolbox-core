-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.ST_MAKEENVELOPE`
    (xmin FLOAT64, ymin FLOAT64, xmax FLOAT64, ymax FLOAT64)
RETURNS GEOGRAPHY
OPTIONS (description="Creates a rectangular Polygon from the minimum and maximum values for X and Y")
AS (
    ST_MAKEPOLYGONORIENTED([ST_GeogFromText(CONCAT('LINESTRING(', LEAST(xmin, xmax), ' ', LEAST(ymin, ymax), ',', 
                                                LEAST(xmin, xmax), ' ', GREATEST(ymin, ymax), ',', 
                                                GREATEST(xmin, xmax), ' ', GREATEST(ymin, ymax), ',', 
                                                GREATEST(xmin, xmax), ' ', LEAST(ymin, ymax),')'))])
);