-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PLACEKEY@@.ISVALID`(placekey STRING)
    RETURNS BOOLEAN
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@PLACEKEY_BQ_LIBRARY@@"])
AS """
    return placekeyIsValid(placekey);
""";
