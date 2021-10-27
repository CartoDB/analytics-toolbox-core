----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ISVALID
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_ISVALID@@

    if (!INDEX) {
        return false;
    }

    return h3Lib.h3IsValid(INDEX);
$$;