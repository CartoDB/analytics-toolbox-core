-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ST_BOUNDARY(index STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX)
        return null;
        
    if (!h3.h3IsValid(INDEX))
        return null;
        
    const coords = h3.h3ToGeoBoundary(INDEX, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_BOUNDARY(index STRING)
    RETURNS GEOGRAPHY
AS $$
    TRY_TO_GEOGRAPHY(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ST_BOUNDARY(INDEX))
$$;
