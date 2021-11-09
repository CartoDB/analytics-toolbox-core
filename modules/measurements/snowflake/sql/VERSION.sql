----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        measurementsLibGlobal = measurementsLib;
    }

    if (typeof(measurementsLibGlobal) === "undefined") {
        setup();
    }

    return measurementsLibGlobal.version;
$$;