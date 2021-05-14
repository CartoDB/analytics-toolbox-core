----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._QUADKEY_FROMQUADINT
(quadint STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if(!QUADINT)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return lib.quadkeyFromQuadint(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.QUADKEY_FROMQUADINT
(quadint BIGINT)
RETURNS STRING
AS $$
    @@SF_PREFIX@@quadkey._QUADKEY_FROMQUADINT(CAST(QUADINT AS STRING))
$$;