----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import cell_to_bounding_box

    if quadbin is None:
        return None

    bbox = cell_to_bounding_box(quadbin)
    return 'POLYGON(({west} {south},{west} {north},{east} {north},{east} {south},{west} {south}))'.format(west=bbox[0], south=bbox[1], east=bbox[2], north=bbox[3])
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_BOUNDARY
(BIGINT)
-- (quadbin)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__QUADBIN_BOUNDARY($1), 4326)
$$ LANGUAGE SQL;
