----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._MAKEENVELOPE`
(xmin FLOAT64, ymin FLOAT64, xmax FLOAT64, ymax FLOAT64)
RETURNS GEOGRAPHY
AS (
    ST_GeogFromText(CONCAT('POLYGON((', xmin, ' ', ymin, ',', xmin, ' ', ymax, ',', xmax, ' ', ymax, ',', xmax, ' ', ymin, ',', xmin, ' ', ymin, '))'))
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`(quadint INT64)
RETURNS GEOGRAPHY
AS (
    COALESCE(
        `@@BQ_PREFIX@@quadkey._MAKEENVELOPE`(
            `@@BQ_PREFIX@@quadkey.__BBOX_E`(quadint),
            `@@BQ_PREFIX@@quadkey.__BBOX_N`(quadint),
            `@@BQ_PREFIX@@quadkey.__BBOX_W`(quadint),
            `@@BQ_PREFIX@@quadkey.__BBOX_S`(quadint)
        ),
        ERROR('NULL argument passed to UDF')
    )
);