----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _DISTANCE
(index1 STRING, index2 STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_DISTANCE@@

    if (!INDEX1 || !INDEX2) {
        return null;
    }
        
    let dist = h3Lib.h3Distance(INDEX1, INDEX2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$$;

CREATE OR REPLACE SECURE FUNCTION DISTANCE
(index1 STRING, index2 STRING)
RETURNS BIGINT
AS $$
    CAST(_DISTANCE(INDEX1, INDEX2) AS BIGINT)
$$;