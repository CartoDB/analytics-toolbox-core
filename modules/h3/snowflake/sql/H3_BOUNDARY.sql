----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __H3_BOUNDARY
(index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    @@SF_LIBRARY_BOUNDARY@@

    if (!h3Lib.h3IsValid(INDEX)) {
        return null;
    }

    const coords = h3Lib.h3ToGeoBoundary(INDEX, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
$$;

CREATE OR REPLACE SECURE FUNCTION H3_BOUNDARY
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(__H3_BOUNDARY(INDEX))
$$;