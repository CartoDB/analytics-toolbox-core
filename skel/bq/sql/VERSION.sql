-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@SKEL_BQ_DATASET@@.VERSION`()
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@SKEL_BQ_LIBRARY@@"])
AS """
    return skelVersion();
""";
