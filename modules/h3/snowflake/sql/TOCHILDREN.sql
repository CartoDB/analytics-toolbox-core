----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _TOCHILDREN
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

CREATE OR REPLACE SECURE FUNCTION TOCHILDREN
(index STRING, resolution INT)
RETURNS ARRAY
AS $$
    _TOCHILDREN(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;