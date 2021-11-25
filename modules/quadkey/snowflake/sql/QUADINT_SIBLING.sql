----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADINT_SIBLING
(quadint STRING, direction STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT || !DIRECTION) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return quadkeyLib.sibling(QUADINT, DIRECTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_SIBLING
(quadint BIGINT, direction STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(__QUADINT_SIBLING(CAST(QUADINT AS STRING),DIRECTION) AS BIGINT)
$$;