----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ISPENTAGON
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_ispentagon@@

    if (!INDEX) {
        return false;
    }

    return h3Lib.h3IsPentagon(INDEX);
$$;