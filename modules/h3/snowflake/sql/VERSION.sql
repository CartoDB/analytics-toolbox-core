----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_VERSION@@
        version = h3Lib.version;
    }

    if (typeof(version) === "undefined") {
        setup();
    }

    return version;
$$;