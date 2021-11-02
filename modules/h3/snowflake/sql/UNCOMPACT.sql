----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._UNCOMPACT
(h3Array ARRAY, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_UNCOMPACT@@

    if (H3ARRAY == null || RESOLUTION == null || RESOLUTION < 0 || RESOLUTION > 15) {
        return [];
    }

    return h3Lib.uncompact(H3ARRAY, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.UNCOMPACT
(h3Array ARRAY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
(
    @@SF_PREFIX@@h3._UNCOMPACT(H3ARRAY, CAST(RESOLUTION AS DOUBLE))
)
$$;