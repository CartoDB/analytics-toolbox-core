----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `%BQ_PROJECT%.%BQ_DATASET%.VERSION`()
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["%BQ_LIBRARY_BUCKET%"])
AS
"""
    return lib.version;
""";
