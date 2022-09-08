----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADINT_BBOX
(quadint STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF.');
    }

    @@SF_LIBRARY_QUADKEY@@

    return quadkeyLib.bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADINT_BBOX
(quadint BIGINT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._QUADINT_BBOX(CAST(QUADINT AS STRING))
$$;