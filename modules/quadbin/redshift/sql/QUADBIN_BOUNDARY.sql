----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import bbox

    if quadbin is None:
        return None

    bbox = bbox(quadbin)
    return 'POLYGON(({west} {south},{west} {north},{east} {north},{east} {south},{west} {south}))'.format(west=bbox[0], south=bbox[1], east=bbox[2], north=bbox[3])
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_BOUNDARY
(BIGINT)
-- (quadbin)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@carto.__QUADBIN_BOUNDARY($1), 4326)
$$ LANGUAGE sql;