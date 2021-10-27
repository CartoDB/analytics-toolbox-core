----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _SIBLING
(quadint STRING, direction STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!QUADINT || !DIRECTION) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.sibling(QUADINT, DIRECTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION SIBLING
(quadint BIGINT, direction STRING)
RETURNS BIGINT
AS $$
    CAST(_SIBLING(CAST(QUADINT AS STRING),DIRECTION) AS BIGINT)
$$;