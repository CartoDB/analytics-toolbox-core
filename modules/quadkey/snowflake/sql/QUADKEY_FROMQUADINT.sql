----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADKEY_FROMQUADINT
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

CREATE OR REPLACE SECURE FUNCTION QUADKEY_FROMQUADINT
(quadint BIGINT)
RETURNS STRING
AS $$
    _QUADKEY_FROMQUADINT(CAST(QUADINT AS STRING))
$$;