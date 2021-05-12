----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.__LINE_INTERPOLATE_POINT`
(geojson STRING, distance FLOAT64, units STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson || distance == null) {
        return null;
    }
    let options = {};
    if(units)
    {
        options.units = units;
    }
    let along = lib.along(JSON.parse(geojson), distance, options);
    return JSON.stringify(along.geometry);
""";


CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT`
(geog GEOGRAPHY, distance FLOAT64, units STRING)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__LINE_INTERPOLATE_POINT`(ST_ASGEOJSON(geog), distance, units))
);