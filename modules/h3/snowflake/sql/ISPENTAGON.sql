----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ISPENTAGON
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!INDEX)
        return false;

    return h3.h3IsPentagon(INDEX);
$$;