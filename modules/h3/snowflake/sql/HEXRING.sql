----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.HEXRING
(index STRING, distance DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!INDEX || DISTANCE == null || DISTANCE < 0)
        return [];
        
    if (!h3.h3IsValid(INDEX))
        return [];

    try {
        return h3.hexRing(INDEX, parseInt(DISTANCE));
    } catch (error) {
        return [];
    }
$$;