----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@constructors.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        constructorsLibGlobal = constructorsLib;
    }

    if (typeof(constructorsLibGlobal) === "undefined") {
        setup();
    }

    return constructorsLibGlobal.version;
$$;