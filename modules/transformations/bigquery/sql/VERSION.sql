----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.VERSION`
()
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@TRANSFORMATIONS_BQ_LIBRARY@@"])
AS """
    return lib.version;
""";
