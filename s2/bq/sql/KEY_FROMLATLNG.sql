-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.KEY_FROMLATLNG`
    (latitude FLOAT64, longitude FLOAT64, level NUMERIC)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    return S2.latLngToKey(latitude, longitude, level);
""";