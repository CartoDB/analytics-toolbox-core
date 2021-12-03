----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _H3_TOPARENT
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    @@SF_LIBRARY_TOPARENT@@

    if (!h3Lib.h3IsValid(INDEX)) {
        return null;
    }

    return h3Lib.h3ToParent(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION H3_TOPARENT
(index STRING, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    _H3_TOPARENT(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;