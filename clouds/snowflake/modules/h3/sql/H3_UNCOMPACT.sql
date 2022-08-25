----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_UNCOMPACT
(h3Array ARRAY, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (H3ARRAY == null || RESOLUTION == null || RESOLUTION < 0 || RESOLUTION > 15) {
        return [];
    }

    @@SF_LIBRARY_UNCOMPACT@@

    return h3Lib.uncompact(H3ARRAY, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_UNCOMPACT
(h3Array ARRAY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
(
    @@SF_SCHEMA@@._H3_UNCOMPACT(H3ARRAY, CAST(RESOLUTION AS DOUBLE))
)
$$;