----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__PLACEKEY_FROMH3`(h3Index STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return placekeyLib.h3ToPlacekey(h3Index);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.PLACEKEY_FROMH3`
(h3Index STRING)
RETURNS STRING
AS (
    IF(`@@BQ_PREFIX@@carto.H3_ISVALID`(h3Index), `@@BQ_PREFIX@@carto.__PLACEKEY_FROMH3`(h3Index), null)
);