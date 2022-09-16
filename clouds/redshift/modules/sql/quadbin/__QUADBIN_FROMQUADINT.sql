----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_FROMQUADINT
(quadint BIGINT)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import tile_to_cell

    z = quadint & 31
    x = (quadint >> 5) & ((1 << z) - 1)
    y = quadint >> (z + 5)

    return tile_to_cell((x, y, z))
$$ LANGUAGE plpythonu;
