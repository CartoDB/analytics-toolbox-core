----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__PLACEKEY_FROMH3`(
    h3Index STRING
)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_PLACEKEY_BUCKET@@"]
)
AS """
    return placekeyLib.h3ToPlacekey(h3Index);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.PLACEKEY_FROMH3`
(h3Index STRING)
RETURNS STRING
AS (
    IF(
        `@@BQ_DATASET@@.H3_ISVALID`(
            h3index
        ),
        `@@BQ_DATASET@@.__PLACEKEY_FROMH3`(
            h3index
        ),
        NULL
    )
);
