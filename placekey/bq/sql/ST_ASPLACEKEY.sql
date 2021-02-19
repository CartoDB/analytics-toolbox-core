-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PLACEKEY@@.LONGLAT_ASPLACEKEY`
    (longitude FLOAT64, latitude FLOAT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@PLACEKEY_BQ_LIBRARY@@"])
AS """
    return geoToPlacekey(latitude, longitude);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PLACEKEY@@.ST_ASPLACEKEY`
    (point GEOGRAPHY)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_PLACEKEY@@.LONGLAT_ASPLACEKEY(ST_X(point), ST_Y(point))
);