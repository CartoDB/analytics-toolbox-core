----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__QUADBIN_CENTER
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
STABLE
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
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@carto.__QUADBIN_CENTER($1), 4326)
$$ LANGUAGE sql;
