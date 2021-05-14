----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._QUADINT_FROMQUADKEY
(quadkey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    return lib.quadintFromQuadkey(QUADKEY).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.QUADINT_FROMQUADKEY
(quadkey STRING)
RETURNS BIGINT
AS $$
    CAST(@@SF_PREFIX@@quadkey._QUADINT_FROMQUADKEY(QUADKEY) AS BIGINT)
$$;