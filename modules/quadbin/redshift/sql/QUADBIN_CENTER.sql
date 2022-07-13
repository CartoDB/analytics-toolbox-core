----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_CENTER
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_center

    if quadbin is None:
        return None

    (x,y) = quadbin_center(quadbin)
    return 'POINT ({} {})'.format(x,y)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_CENTER
(BIGINT)
-- (quadbin)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@carto.__QUADBIN_CENTER($1), 4326)
$$ LANGUAGE sql;
