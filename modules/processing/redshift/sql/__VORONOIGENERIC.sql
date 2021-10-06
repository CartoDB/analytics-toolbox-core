----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.__VORONOIGENERIC
(points VARCHAR(MAX), bbox VARCHAR(MAX), voronoi_type VARCHAR(15))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$ 
    from @@RS_PREFIX@@processingLib import voronoi_generic, PRECISION
    import geojson
    import json
    
    bbox_array = []
    if bbox is not None:
        bbox_array = json.loads(bbox)

    if points is None:
        return None

    if voronoi_type != 'lines' and voronoi_type != 'poly':
        return None

    if bbox is not None and len(bbox_array) != 4:
        return None

    _geom = json.loads(points)
    _geom['precision'] = PRECISION
    geom_geojson = json.dumps(_geom)
    geom_geojson = geojson.loads(geom_geojson)

    return str(voronoi_generic(geom_geojson, bbox_array, voronoi_type, PRECISION))

$$ LANGUAGE plpythonu;