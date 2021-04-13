-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_SQUELLETON@@.__BUFFER`
    (geojson STRING, radius FLOAT64, unit STRING, steps INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@SQUELLETON_BQ_LIBRARY@@"])
AS """
    if (!geojson || radius == null || !unit || steps == null) {
        return null;
    }
    var buffer = turf.buffer(JSON.parse(geojson), Number(radius),{'unit': unit, 'steps': Number(steps)});
    return JSON.stringify(buffer.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_SQUELLETON@@.ST_BUFFER`
    (geog GEOGRAPHY, radius FLOAT64, units STRING, steps INT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_SQUELLETON@@.__BUFFER(ST_ASGEOJSON(geog),radius, units, steps))
);