----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.PLACEKEY_TOH3`
(placekey STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_PLACEKEY_BUCKET@@"]
)
AS """
    if (!placekeyLib.placekeyIsValid(placekey))  {
        return null;
    }
    return placekeyLib.placekeyToH3(placekey);
""";
