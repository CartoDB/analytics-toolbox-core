-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.VERSION`()
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TRANSFORMATION_BQ_LIBRARY@@"])
AS """
    return transformationVersion();
""";
