-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.COMPACT`
(h3Array ARRAY<STRING>)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS
"""
    if (h3Array === null) {
        return null;
    }
    return lib.compact(h3Array);
""";

