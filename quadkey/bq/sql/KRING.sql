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
    var left      = sibling(quadint,'left');
    var topleft   = sibling(left,'up');
    var downleft  = sibling(left,'down');
    var right     = sibling(quadint,'right');
    var topright  = sibling(right,'up');
    var downright = sibling(right,'down');
    var up        = sibling(quadint,'up');
    var down      = sibling(quadint,'down');

    return [left,topleft,downleft,right,topright,downright,up,down,quadint];
""";