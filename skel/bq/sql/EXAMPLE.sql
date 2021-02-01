-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_SKEL@@.EXAMPLE_ADD`(value INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@SKEL_BQ_LIBRARY@@"])
AS """
    return skelExampleAdd(parseInt(value));
""";
