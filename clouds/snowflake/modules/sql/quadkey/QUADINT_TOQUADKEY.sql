----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADINT_TOQUADKEY
(quadint STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_QUADKEY@@

    return quadkeyLib.quadkeyFromQuadint(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADINT_TOQUADKEY
(quadint BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._QUADINT_TOQUADKEY(CAST(QUADINT AS STRING))
$$;