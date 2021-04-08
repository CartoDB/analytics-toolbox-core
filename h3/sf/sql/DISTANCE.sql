-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._DISTANCE(index1 STRING, index2 STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!INDEX1 || !INDEX2)
        return null;
        
    let dist = h3.h3Distance(INDEX1, INDEX2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.DISTANCE(index1 STRING, index2 STRING)
    RETURNS BIGINT
AS $$
    CAST(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._DISTANCE(INDEX1, INDEX2) AS BIGINT)
$$;