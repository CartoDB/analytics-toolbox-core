----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._TOPARENT
(quadint STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

   function setup() {
        @@SF_LIBRARY_CONTENT@@
        quadkeyLibGlobal = quadkeyLib;
    }

    if (typeof(quadkeyLibGlobal) === "undefined") {
        setup();
    }

    return quadkeyLibGlobal.toParent(QUADINT, RESOLUTION).toString();
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.TOPARENT
(quadint BIGINT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_PREFIX@@quadkey._TOPARENT(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;