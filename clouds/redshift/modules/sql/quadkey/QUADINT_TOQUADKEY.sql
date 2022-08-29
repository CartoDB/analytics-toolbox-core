----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_TOQUADKEY
(quadint BIGINT)
RETURNS VARCHAR
STABLE
AS $$
    from @@RS_LIBRARY@@.quadkey import quadkey_from_quadint

    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    return quadkey_from_quadint(quadint)
$$ LANGUAGE plpythonu;