----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT
(longitude FLOAT8, latitude FLOAT8, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    if longitude is None or latitude is None or resolution is None:
        return None

    if resolution < 0 or resolution > 26:
        raise Exception('Invalid resolution: should be between 0 and 26')

    from @@RS_LIBRARY@@.quadbin import point_to_cell

    return point_to_cell(longitude, latitude, resolution)
$$ LANGUAGE PLPYTHONU;
