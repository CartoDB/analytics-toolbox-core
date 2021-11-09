----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._ST_BOUNDARY
(index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_BOUNDARY@@
        h3ToGeoBoundary = h3Lib.h3ToGeoBoundary;
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(h3ToGeoBoundary) === "undefined" || typeof(h3IsValid) === "undefined") {
        setup();
    }
    
    if (!h3IsValid(INDEX)) {
        return null;
    }

    const coords = h3ToGeoBoundary(INDEX, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ST_BOUNDARY
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(@@SF_PREFIX@@h3._ST_BOUNDARY(INDEX))
$$;