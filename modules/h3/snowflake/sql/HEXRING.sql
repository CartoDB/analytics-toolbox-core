----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._HEXRING
(index STRING, distance DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_hexring@@

    if (!INDEX || DISTANCE == null || DISTANCE < 0) {
        return [];
    }

    if (!h3Lib.h3IsValid(INDEX)) {
        return [];
    }

    try {
        return h3Lib.hexRing(INDEX, parseInt(DISTANCE));
    } catch (error) {
        return [];
    }
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.HEXRING
(index STRING, distance INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._HEXRING(INDEX, CAST(DISTANCE AS DOUBLE))
$$;