-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._COMPACT(h3Array ARRAY)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    if (H3ARRAY === null) {
        return null;
    }
    return h3.compact(H3ARRAY).map(h => '0x' + h);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.COMPACT(h3Array ARRAY)
    RETURNS ARRAY
AS $$
(
    SELECT @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._COMPACT(ARRAY_AGG(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_ASHEX(x))) FROM unnest(H3ARRAY) x
)
$$;


CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._UNCOMPACT(h3Array ARRAY, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    if (H3ARRAY === null || RESOLUTION === null || RESOLUTION < 0 || RESOLUTION > 15) {
        return null;
    }
    return h3.uncompact(H3ARRAY, Number(RESOLUTION)).map(h => '0x' + h);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.UNCOMPACT(h3Array ARRAY, resolution INT)
    RETURNS ARRAY
AS $$
(
    SELECT @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._UNCOMPACT(ARRAY_AGG(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_ASHEX(x)), CAST(RESOLUTION AS DOUBLE)) FROM unnest(H3ARRAY) x
)
$$;