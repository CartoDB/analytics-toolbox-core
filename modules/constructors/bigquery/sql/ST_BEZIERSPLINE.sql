----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@constructors.ST_BEZIERSPLINE`
(geog GEOGRAPHY, resolution INT64, sharpness FLOAT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@constructors.__BEZIERSPLINE`(ST_ASGEOJSON(geog), resolution, sharpness))
);
