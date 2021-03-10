-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING
    (quadint DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@
    
    if(QUADINT == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    var left      = sibling(QUADINT,'left');
    var topleft   = sibling(left,'up');
    var downleft  = sibling(left,'down');
    var right     = sibling(QUADINT,'right');
    var topright  = sibling(right,'up');
    var downright = sibling(right,'down');
    var up        = sibling(QUADINT,'up');
    var down      = sibling(QUADINT,'down');

    return [left, topleft, downleft, right, topright, downright, up, down, QUADINT];
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING
    (quadint INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.KRING(CAST(QUADINT AS DOUBLE))
$$;