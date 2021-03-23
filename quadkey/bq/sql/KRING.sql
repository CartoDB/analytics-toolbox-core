-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.KRING`
    (quadint INT64, distance INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
if(quadint == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    if(distance == null)
    {
        distance = 1;
    }
    let neighbors = kring(quadint, Number(distance));
    return neighbors.map(String);
""";