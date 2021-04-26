-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATIONS@@.__MAKEELLIPSE`
    (geojson STRING, xSemiAxis FLOAT64, ySemiAxis FLOAT64, angle FLOAT64, units STRING, steps INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TRANSFORMATIONS_BQ_LIBRARY@@"])
AS """
    if (!geojson || xSemiAxis == null || ySemiAxis == null) {
        return null;
    }
    let options = {};
    if(angle != null)
    {
        options.angle = Number(angle);
    }
    if(units)
    {
        options.units = units;
    }
    if(steps != null)
    {
        options.steps = Number(steps);
    }
    let ellipse = turf.ellipse(JSON.parse(geojson), Number(xSemiAxis), Number(ySemiAxis), options);
    return JSON.stringify(ellipse.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATIONS@@.ST_MAKEELLIPSE`
    (geog GEOGRAPHY, xSemiAxis FLOAT64, ySemiAxis FLOAT64, angle FLOAT64, units STRING, steps INT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TRANSFORMATIONS@@.__MAKEELLIPSE(ST_ASGEOJSON(geog), xSemiAxis, ySemiAxis, angle, units, steps))
);