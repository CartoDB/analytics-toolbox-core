-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.BBOX`
    (quadint INT64)
    RETURNS ARRAY<FLOAT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    var b = bbox(quadint);  
    return [b.min.lng, b.min.lat, b.max.lng, b.max.lat];
""";