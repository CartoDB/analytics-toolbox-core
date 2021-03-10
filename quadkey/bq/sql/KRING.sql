-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_QUADKEY@@.KRING`
    (quadint INT64, distance INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@QUADKEY_BQ_LIBRARY@@"])
AS """
    if(quadint == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    if(distance == null)
    {
        distance = 0;
    }
    let neighbors = [sibling(quadint,'up').toString()];
    let moves = ['left','down','right','up'];
    var i;
    for (i = 1; i < (1+2*distance)*(1+2*distance)-1; i++) {
        neighbors.push(sibling(neighbors[neighbors.length-1],moves[Math.floor(i/2)%4]).toString());
    }
    neighbors.push(quadint.toString());
    return neighbors;
""";