----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADINT_TOQUADKEY
(quadint STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return quadkeyLib.quadkeyFromQuadint(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_TOQUADKEY
(quadint BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    __QUADINT_TOQUADKEY(CAST(QUADINT AS STRING))
$$;