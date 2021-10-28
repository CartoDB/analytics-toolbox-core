----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _H3_TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_TOCHILDREN@@

    if (!INDEX) {
        return [];
    }
   
    if (!h3Lib.h3IsValid(INDEX)) {
        return [];
    }

    return h3Lib.h3ToChildren(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION H3_TOCHILDREN
(index STRING, resolution INT)
RETURNS ARRAY
AS $$
    _H3_TOCHILDREN(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;