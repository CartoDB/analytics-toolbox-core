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
    var left      = sibling(quadint,'left').toString();
    var topleft   = sibling(left,'up').toString();
    var downleft  = sibling(left,'down').toString();
    var right     = sibling(quadint,'right').toString();
    var topright  = sibling(right,'up').toString();
    var downright = sibling(right,'down').toString();
    var up        = sibling(quadint,'up').toString();
    var down      = sibling(quadint,'down').toString();

    return [left, topleft, downleft, right, topright, downright, up, down, quadint];
""";