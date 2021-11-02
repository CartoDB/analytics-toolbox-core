----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._SIBLING
(quadint STRING, direction STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!QUADINT || !DIRECTION) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.sibling(QUADINT, DIRECTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.SIBLING
(quadint BIGINT, direction STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_PREFIX@@quadkey._SIBLING(CAST(QUADINT AS STRING),DIRECTION) AS BIGINT)
$$;