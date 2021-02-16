-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_SPHERICALMERCATOR@@.VERSION`()
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@SPHERICALMERCATOR_BQ_LIBRARY@@"])
AS """
    return sphericalmercatorVersion();
""";
