----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION H3_ISVALID
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_ISVALID@@

    if (!INDEX) {
        return false;
    }

    return h3Lib.h3IsValid(INDEX);
$$;