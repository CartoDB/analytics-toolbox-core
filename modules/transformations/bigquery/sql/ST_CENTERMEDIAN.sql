----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.__CENTERMEDIAN`
(geojson STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@TRANSFORMATIONS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    let medianCenter = turf.centerMedian(turf.feature(JSON.parse(geojson)));
    return JSON.stringify(medianCenter.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_CENTERMEDIAN`
(geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__CENTERMEDIAN`(ST_ASGEOJSON(geog)))
);