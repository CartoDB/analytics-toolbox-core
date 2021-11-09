----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        processingLibGlobal = processingLib;
    }

    if (typeof(processingLibGlobal) === "undefined") {
        setup();
    }

    return processingLibGlobal.version;
$$;