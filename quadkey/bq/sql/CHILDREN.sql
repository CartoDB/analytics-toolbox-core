-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.CHILDREN`
    (quadint INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if(quadint == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    let quadints = children(quadint);
    return quadints.map(String);
""";