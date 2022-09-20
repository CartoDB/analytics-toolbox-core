----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADINT_SIBLING
(quadint STRING, direction STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT || !DIRECTION) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_QUADKEY@@

    return quadkeyLib.sibling(QUADINT, DIRECTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADINT_SIBLING
(quadint BIGINT, direction STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_SCHEMA@@._QUADINT_SIBLING(CAST(QUADINT AS STRING),DIRECTION) AS BIGINT)
$$;
