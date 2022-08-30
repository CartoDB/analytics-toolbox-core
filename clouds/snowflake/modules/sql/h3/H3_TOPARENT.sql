----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_TOPARENT
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    @@SF_LIBRARY_H3_TOPARENT@@

    if (!h3ToparentLib.h3IsValid(INDEX)) {
        return null;
    }

    return h3ToparentLib.h3ToParent(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_TOPARENT
(index STRING, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._H3_TOPARENT(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;