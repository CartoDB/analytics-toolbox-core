----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@constructors.ST_MAKEENVELOPE`
(xmin FLOAT64, ymin FLOAT64, xmax FLOAT64, ymax FLOAT64)
RETURNS GEOGRAPHY
OPTIONS (description="Creates a rectangular Polygon from the minimum and maximum values for X and Y")
AS (
    ST_MAKEPOLYGON(ST_GeogFromText(CONCAT('LINESTRING(', xmin, ' ', ymin, ',', xmin, ' ', ymax, ',', xmax, ' ', ymax, ',', xmax, ' ', ymin,')')))
);