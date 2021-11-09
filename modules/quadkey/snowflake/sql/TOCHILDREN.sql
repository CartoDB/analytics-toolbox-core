----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._TOCHILDREN
(quadint STRING, resolution DOUBLE)
RETURNS ARRAY
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

    const quadints = quadkeyLibGlobal.toChildren(QUADINT, RESOLUTION);
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.TOCHILDREN
(quadint BIGINT, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@quadkey._TOCHILDREN(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;