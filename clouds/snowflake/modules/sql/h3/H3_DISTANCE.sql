----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_DISTANCE
(index1 STRING, index2 STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX1 || !INDEX2) {
        return null;
    }

    @@SF_LIBRARY_H3_DISTANCE@@

    let dist = h3DistanceLib.h3Distance(INDEX1, INDEX2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_DISTANCE
(index1 STRING, index2 STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_SCHEMA@@._H3_DISTANCE(INDEX1, INDEX2) AS BIGINT)
$$;