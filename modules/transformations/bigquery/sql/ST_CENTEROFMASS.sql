----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.__CENTEROFMASS`
(geojson STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    var center = turf.centerOfMass(JSON.parse(geojson));
    return JSON.stringify(center.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_CENTEROFMASS`
(geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__CENTEROFMASS`(ST_ASGEOJSON(geog)))
);