----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._QUADKEY_FROMQUADINT
(quadint STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        quadkeyLibGlobal = quadkeyLib;
    }

    if (typeof(quadkeyLibGlobal) === "undefined") {
        setup();
    }

    return quadkeyLibGlobal.quadkeyFromQuadint(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.QUADKEY_FROMQUADINT
(quadint BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_PREFIX@@quadkey._QUADKEY_FROMQUADINT(CAST(QUADINT AS STRING))
$$;