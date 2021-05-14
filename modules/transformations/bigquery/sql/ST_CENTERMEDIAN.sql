----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.__CENTERMEDIAN`
(geojson STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    const medianCenter = lib.centerMedian(lib.feature(JSON.parse(geojson)));
    return JSON.stringify(medianCenter.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_CENTERMEDIAN`
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__CENTERMEDIAN`(ST_ASGEOJSON(geog)))
);