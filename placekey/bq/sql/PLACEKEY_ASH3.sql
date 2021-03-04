-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PLACEKEY@@.PLACEKEY_ASH3`(placekey STRING)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@PLACEKEY_BQ_LIBRARY@@"])
AS """
    if (!placekeyIsValid(placekey))  {
        return null;
    }
    return '0x' + placekeyToH3(placekey);
""";
