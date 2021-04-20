-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.VERSION`()
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@PROCESSING_BQ_LIBRARY@@"])
AS """
    return processingVersion();
""";
