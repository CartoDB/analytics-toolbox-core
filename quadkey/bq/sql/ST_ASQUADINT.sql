-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.LONGLAT_ASQUADINT`
    (longitude FLOAT64, latitude FLOAT64, resolution INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if(longitude == null || latitude == null || resolution == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return quadintFromLocation(Number(longitude), Number(latitude), Number(resolution)).toString();
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.ST_ASQUADINT`
    (point GEOGRAPHY, resolution INT64) 
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_QUADKEY@@.LONGLAT_ASQUADINT(ST_X(point), ST_Y(point), resolution)
);