----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADINT_BBOX
(quadint STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return quadkeyLib.bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_BBOX
(quadint BIGINT)
RETURNS ARRAY
IMMUTABLE
AS $$
    __QUADINT_BBOX(CAST(QUADINT AS STRING))
$$;