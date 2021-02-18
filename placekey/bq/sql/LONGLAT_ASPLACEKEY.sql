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
    OPTIONS (library=["@@H3_BQ_LIBRARY@@", "@@PLACEKEY_BQ_LIBRARY@@"])
AS """
    return geoToPlacekey(latitude, longitude);
""";
