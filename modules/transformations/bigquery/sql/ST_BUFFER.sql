----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__BUFFER`
(geojson STRING, radius FLOAT64, units STRING, steps INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson || radius == null) {
        return null;
    }
    const options = {};
    if (units) {
        options.units = units;
    }
    if (steps != null) {
        options.steps = Number(steps);
    }
    const buffer = transformationsLib.buffer(JSON.parse(geojson), Number(radius), options);
    return JSON.stringify(buffer.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.ST_BUFFER`
(geog GEOGRAPHY, radius FLOAT64, units STRING, steps INT64)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@carto.__BUFFER`(ST_ASGEOJSON(geog),radius, units, steps))
);