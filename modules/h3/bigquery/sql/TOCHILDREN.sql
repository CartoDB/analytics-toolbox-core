----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.TOCHILDREN`
(index STRING, resolution INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS
"""
    if (!index)
        return null;

    if (!lib.h3IsValid(index))
        return null;

    return lib.h3ToChildren(index, Number(resolution));
""";
