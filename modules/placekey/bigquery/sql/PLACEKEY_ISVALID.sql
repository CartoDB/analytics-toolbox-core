----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@placekey.PLACEKEY_ISVALID`
(placekey STRING)
RETURNS BOOLEAN
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return placekeyLib.placekeyIsValid(placekey);
""";