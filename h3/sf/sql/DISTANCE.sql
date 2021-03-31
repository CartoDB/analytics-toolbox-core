-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._DISTANCE(index_lower1 DOUBLE, index_upper1 DOUBLE, index_lower2 DOUBLE, index_upper2 DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (INDEX_LOWER1 == null || INDEX_UPPER1 == null || INDEX_LOWER2 == null || INDEX_UPPER2 == null)
        return null;
    const index1 = [Number(INDEX_LOWER1), Number(INDEX_UPPER1)];
    const index2 = [Number(INDEX_LOWER2), Number(INDEX_UPPER2)];
    let dist = h3.h3Distance(index1, index2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.DISTANCE(index1 BIGINT, index2 BIGINT)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._DISTANCE(
        CAST(BITAND(INDEX1, 4294967295) AS DOUBLE), 
        CAST(BITSHIFTRIGHT(INDEX1, 32) AS DOUBLE),
        CAST(BITAND(INDEX2, 4294967295) AS DOUBLE), 
        CAST(BITSHIFTRIGHT(INDEX2, 32) AS DOUBLE)) AS BIGINT)
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.DISTANCE(index1 STRING, index2 STRING)
    RETURNS BIGINT
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.DISTANCE(
        @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(INDEX1), 
        @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(INDEX2))
$$;