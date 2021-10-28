----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADINT_TOQUADKEY
(quadint STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.quadkeyFromQuadint(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_TOQUADKEY
(quadint BIGINT)
RETURNS STRING
AS $$
    _QUADINT_TOQUADKEY(CAST(QUADINT AS STRING))
$$;