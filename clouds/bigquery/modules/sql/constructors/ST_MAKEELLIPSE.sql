----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__MAKEELLIPSE`
(
    geojson STRING,
    xSemiAxis FLOAT64,
    ySemiAxis FLOAT64,
    angle FLOAT64,
    units STRING,
    steps INT64
)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_BUCKET@@"]
)
AS """
    if (!geojson || xSemiAxis == null || ySemiAxis == null) {
        return null;
    }
    const options = {};
    if (angle != null) {
        options.angle = Number(angle);
    }
    if (units) {
        options.units = units;
    }
    if (steps != null) {
        options.steps = Number(steps);
    }
    const ellipse = lib.constructors.ellipse(JSON.parse(geojson), Number(xSemiAxis), Number(ySemiAxis), options);
    return JSON.stringify(ellipse.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_MAKEELLIPSE`
(
    geog GEOGRAPHY,
    xSemiAxis FLOAT64,
    ySemiAxis FLOAT64,
    angle FLOAT64,
    units STRING,
    steps INT64
)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(
        `@@BQ_DATASET@@.__MAKEELLIPSE`(
            ST_ASGEOJSON(geog), xsemiaxis, ysemiaxis, angle, units, steps
        )
    )
);
