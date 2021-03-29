-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ST_BOUNDARY(index_lower DOUBLE, index_upper DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (INDEX_LOWER == null || INDEX_UPPER == null)
        return null;
    const h3IndexInput = [Number(INDEX_LOWER), Number(INDEX_UPPER)];
    if (!h3.h3IsValid(h3IndexInput))
        return null;
    const coords = h3.h3ToGeoBoundary(h3IndexInput, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_BOUNDARY(index BIGINT)
    RETURNS GEOGRAPHY
AS $$
    TO_GEOGRAPHY(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ST_BOUNDARY(
        CAST(BITAND(INDEX, 4294967295) AS DOUBLE), 
        CAST(BITSHIFTRIGHT(INDEX, 32) AS DOUBLE)))
$$;