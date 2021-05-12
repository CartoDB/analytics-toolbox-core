----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.__BUFFER`
(geojson STRING, radius FLOAT64, units STRING, steps INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson || radius == null) {
        return null;
    }
    let options = {};
    if(units)
    {
        options.units = units;
    }
    if(steps != null)
    {
        options.steps = Number(steps);
    }
    let buffer = lib.buffer(JSON.parse(geojson), Number(radius), options);
    return JSON.stringify(buffer.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_BUFFER`
(geog GEOGRAPHY, radius FLOAT64, units STRING, steps INT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__BUFFER`(ST_ASGEOJSON(geog),radius, units, steps))
);