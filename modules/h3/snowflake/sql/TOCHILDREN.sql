----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!INDEX)
        return [];
        
    if (!h3.h3IsValid(INDEX))
        return [];

    return h3.h3ToChildren(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.TOCHILDREN
(index STRING, resolution INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._TOCHILDREN(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;
