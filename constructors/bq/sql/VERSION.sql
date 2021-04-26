-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.VERSION`()
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
AS """
    return '1.0.0';
""";