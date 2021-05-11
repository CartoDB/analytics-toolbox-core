----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@constructors.ST_MAKEELLIPSE`
(geog GEOGRAPHY, xSemiAxis FLOAT64, ySemiAxis FLOAT64, angle FLOAT64, units STRING, steps INT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@constructors.__MAKEELLIPSE`(ST_ASGEOJSON(geog), xSemiAxis, ySemiAxis, angle, units, steps))
);