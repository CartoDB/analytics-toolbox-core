----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ISPENTAGON
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_ISPENTAGON@@

    if (!INDEX) {
        return false;
    }

    return h3Lib.h3IsPentagon(INDEX);
$$;