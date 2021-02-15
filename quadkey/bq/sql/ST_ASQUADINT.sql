-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.QUADINT_FROMLOCATION`
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
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.QUADINT_FROMLOCATION(ST_Y(point),ST_X(point),resolution)
);