----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._BBOX
(quadint STRING)
RETURNS ARRAY
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

    return quadkeyLibGlobal.bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.BBOX
(quadint BIGINT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@quadkey._BBOX(CAST(QUADINT AS STRING))
$$;