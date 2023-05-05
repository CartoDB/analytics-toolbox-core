----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_DISTANCE(
    index1 VARCHAR(16),
    index2 VARCHAR(16)
)
RETURNS BIGINT
AS
$BODY$
    if (!index1 || !index2) {
        return null;
    }

    @@PG_LIBRARY_H3@@

    let dist = h3Lib.h3Distance(index1, index2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
