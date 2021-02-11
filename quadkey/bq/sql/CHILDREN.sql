-----------------------------------------------------------------------
--
-- Copyright (C) 2020 - 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.CHILDREN`
    (quadint INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@BQ_LIBRARY_QUADKEY@@"])
AS """
    return children(quadint);  
""";