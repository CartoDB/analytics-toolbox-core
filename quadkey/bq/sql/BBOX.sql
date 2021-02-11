-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.BBOX`
    (quadint INT64)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@BQ_LIBRARY_QUADKEY@@"])
AS """
    var b= bbox(quadint);  
    return [b.min.lng,b.min.lat,b.max.lng,b.max.lat];
""";