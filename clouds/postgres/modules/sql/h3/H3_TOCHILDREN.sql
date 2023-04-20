----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_TOCHILDREN(
    index VARCHAR(16),
    resolution INT
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    if (!index) {
        return [];
    }

    @@PG_LIBRARY_H3@@

    if (!h3Lib.h3IsValid(index)) {
        return [];
    }

    return h3Lib.h3ToChildren(index, Number(resolution));
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
