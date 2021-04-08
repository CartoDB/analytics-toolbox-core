-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.COMPACT(h3Array ARRAY)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (H3ARRAY == null) {
        return [];
    }
    
    return h3.compact(H3ARRAY);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._UNCOMPACT(h3Array ARRAY, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (H3ARRAY == null || RESOLUTION == null || RESOLUTION < 0 || RESOLUTION > 15) {
        return [];
    }
    
    return h3.uncompact(H3ARRAY, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.UNCOMPACT(h3Array ARRAY, resolution INT)
    RETURNS ARRAY
AS $$
(
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._UNCOMPACT(H3ARRAY, CAST(RESOLUTION AS DOUBLE))
)
$$;