----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.__VORONOIGENERIC
(points VARCHAR(MAX), voronoi_type VARCHAR(15))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$ 
    from @@RS_PREFIX@@processingLib import voronoi_generic
    import geojson

    if points is None:
        return None

    if voronoi_type != 'lines' and voronoi_type != 'poly':
        return None

    return str(voronoi_generic(geojson.loads(points), voronoi_type))

$$ LANGUAGE plpythonu;