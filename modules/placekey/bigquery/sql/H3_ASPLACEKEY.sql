----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@placekey.__H3_ASPLACEKEY`(h3Index STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return lib.h3ToPlacekey(h3Index);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@placekey.H3_ASPLACEKEY`
(h3Index STRING)
RETURNS STRING
AS (
    IF(`@@BQ_PREFIX@@h3.ISVALID`(h3Index), `@@BQ_PREFIX@@placekey.__H3_ASPLACEKEY`(h3Index), null)
);