----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._DISTANCE
(index1 STRING, index2 STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX1 || !INDEX2) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_DISTANCE@@
        h3Distance = h3Lib.h3Distance;
    }

    if (typeof(h3Distance) === "undefined") {
        setup();
    }

    let dist = h3Distance(INDEX1, INDEX2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.DISTANCE
(index1 STRING, index2 STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_PREFIX@@h3._DISTANCE(INDEX1, INDEX2) AS BIGINT)
$$;