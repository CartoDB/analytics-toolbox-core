----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_TOPARENT(
    index VARCHAR(16),
    resolution INT
)
RETURNS VARCHAR(16)
AS $$
    if (!index) {
        return null;
    }

    @@PG_LIBRARY_H3@@

    if (!h3Lib.h3IsValid(index)) {
        return null;
    }

    return h3Lib.h3ToParent(index, Number(resolution));
$$ LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
