----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADINT_TOPARENT
(quadint STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return quadkeyLib.toParent(QUADINT, RESOLUTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_TOPARENT
(quadint BIGINT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(_QUADINT_TOPARENT(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;