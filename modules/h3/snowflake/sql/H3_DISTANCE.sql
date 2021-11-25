----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __H3_DISTANCE
(index1 STRING, index2 STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX1 || !INDEX2) {
        return null;
    }

    @@SF_LIBRARY_DISTANCE@@

    let dist = h3Lib.h3Distance(INDEX1, INDEX2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$$;

CREATE OR REPLACE SECURE FUNCTION H3_DISTANCE
(index1 STRING, index2 STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(__H3_DISTANCE(INDEX1, INDEX2) AS BIGINT)
$$;