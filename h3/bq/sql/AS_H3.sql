-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.LONGLAT_ASH3`(longitude FLOAT64, latitude FLOAT64, resolution INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    const index = h3.geoToH3(latitude, longitude, resolution);
    if (index) {
        return '0x' + index;
    }
    return null;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.ST_ASH3`(geog GEOGRAPHY, resolution INT64)
    RETURNS INT64
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.LONGLAT_ASH3`(SAFE.ST_X(geog), SAFE.ST_Y(geog), resolution)
);
