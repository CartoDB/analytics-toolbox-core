----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_H3_TOCHILDREN@@

    if (!h3TochildrenLib.h3IsValid(INDEX)) {
        return [];
    }

    return h3TochildrenLib.h3ToChildren(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_TOCHILDREN
(index STRING, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._H3_TOCHILDREN(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;
