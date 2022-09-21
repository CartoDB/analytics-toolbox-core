----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_MAKEENVELOPE`
(
    xmin FLOAT64,
    ymin FLOAT64,
    xmax FLOAT64,
    ymax FLOAT64
)
RETURNS GEOGRAPHY
AS (
    ST_MAKEPOLYGON(
        ST_MAKELINE(
            [
                ST_GEOGPOINT(xmin, ymin),
                ST_GEOGPOINT(xmin, ymax),
                ST_GEOGPOINT(xmax, ymax),
                ST_GEOGPOINT(xmax, ymin),
                ST_GEOGPOINT(xmin, ymin)
            ]
        )
    )
);
