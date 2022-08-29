----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_FROMLONGLAT
(longitude FLOAT8, latitude FLOAT8, resolution INT)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_LIBRARY@@.quadkey import quadint_from_location

    if longitude is None or latitude is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return quadint_from_location(longitude, latitude, resolution)
$$ LANGUAGE plpythonu;