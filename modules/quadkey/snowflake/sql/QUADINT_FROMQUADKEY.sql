----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._QUADINT_FROMQUADKEY
(quadkey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        quadkeyLibGlobal = quadkeyLib;
    }

    if (typeof(quadkeyLibGlobal) === "undefined") {
        setup();
    }

    return quadkeyLibGlobal.quadintFromQuadkey(QUADKEY).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.QUADINT_FROMQUADKEY
(quadkey STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_PREFIX@@quadkey._QUADINT_FROMQUADKEY(QUADKEY) AS BIGINT)
$$;