-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.LONGLAT_ASID`
    (longitude FLOAT64, latitude FLOAT64, level INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    if(longitude == null || longitude == null || longitude == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return S2.latLngToId(Number(latitude), Number(longitude), Number(level));
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ST_ASID`
    (point GEOGRAPHY, resolution INT64)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.LONGLAT_ASID(ST_X(point), ST_Y(point), resolution)
);
