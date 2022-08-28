----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_ISPENTAGON
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return false;
    }

    @@SF_LIBRARY_H3_ISPENTAGON@@

    return h3_ispentagonLib.h3IsPentagon(INDEX);
$$;