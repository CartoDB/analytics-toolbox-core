-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.KRING`
    (quadint INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if(quadint == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    let left      = sibling(quadint,'left').toString();
    let topleft   = sibling(left,'up').toString();
    let downleft  = sibling(left,'down').toString();
    let right     = sibling(quadint,'right').toString();
    let topright  = sibling(right,'up').toString();
    let downright = sibling(right,'down').toString();
    let up        = sibling(quadint,'up').toString();
    let down      = sibling(quadint,'down').toString();

    return [left, topleft, downleft, right, topright, downright, up, down, quadint];
""";