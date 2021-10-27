----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _TOPARENT
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_TOPARENT@@

    if (!INDEX) {
        return null;
    }

    if (!h3Lib.h3IsValid(INDEX)) {
        return null;
    }

    return h3Lib.h3ToParent(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION TOPARENT
(index STRING, resolution INT)
RETURNS STRING
AS $$
    _TOPARENT(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;