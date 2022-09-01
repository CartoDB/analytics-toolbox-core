----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.PLACEKEY_TOH3`
(placekey STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!coreLib.placekey.placekeyIsValid(placekey))  {
        return null;
    }
    return coreLib.placekey.placekeyToH3(placekey);
""";