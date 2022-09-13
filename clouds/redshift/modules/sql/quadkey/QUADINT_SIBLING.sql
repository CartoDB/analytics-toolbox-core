----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_SIBLING
(quadint BIGINT, direction VARCHAR)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_LIBRARY@@.quadkey import sibling

    if quadint is None or direction is None:
        raise Exception('NULL argument passed to UDF')

    return sibling(quadint, direction)
$$ LANGUAGE PLPYTHONU;
