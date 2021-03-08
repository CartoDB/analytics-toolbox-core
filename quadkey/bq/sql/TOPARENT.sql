-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.TOPARENT`
    (quadint INT64, resolution INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if(quadint == null || resolution == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    return toParent(quadint, resolution).toString();  
""";
