-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.LONGLAT_ASQUADINT`
    (latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    return quadintFromLocation({ lat: latitude, lng: longitude }, resolution).toString();
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_ASQUADINT`
    (point GEOGRAPHY, resolution NUMERIC) 
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.LONGLAT_ASQUADINT(ST_Y(point),ST_X(point),resolution)
);