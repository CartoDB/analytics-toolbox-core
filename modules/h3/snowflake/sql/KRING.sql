----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._KRING
(index STRING, distance DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!INDEX || DISTANCE == null || DISTANCE < 0)
        return [];
        
    if (!h3.h3IsValid(INDEX))
        return [];

    return h3.kRing(INDEX, parseInt(DISTANCE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.KRING
(index STRING, distance INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._KRING(INDEX, CAST(DISTANCE AS DOUBLE))
$$;
