----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_FROMZXY
(z BIGINT, x BIGINT, y BIGINT)
RETURNS BIGINT
IMMUTABLE
AS $$
    if z is None or x is None or y is None:
        raise Exception('NULL argument passed to UDF')

    from @@RS_LIBRARY@@.quadbin import tile_to_cell

    return tile_to_cell((x, y, z))
$$ LANGUAGE plpythonu;
