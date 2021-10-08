----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.__DELAUNAYGENERIC
(points VARCHAR(MAX), delaunay_type VARCHAR(15))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@processingLib import PRECISION
    import geojson
    import json
    from scipy.spatial import Delaunay

    if points is None:
        return None

    if delaunay_type != 'lines' and delaunay_type != 'poly':
        return None
 
    # Take the type of geometry
    _geom = json.loads(points)
    _geom['precision'] = PRECISION
    geom = json.dumps(_geom)
    geom = geojson.loads(geom)
    
    coords = []
    if geom.type != 'MultiPoint':
        raise Exception('Invalid operation: Input points parameter must be MultiPoint.')
    else:
        coords = list(geojson.utils.coords(geom))

    tri = Delaunay(coords)

    lines = []
    for triangle in tri.simplices:
        p_1 = coords[triangle[0]]
        p_2 = coords[triangle[1]]
        p_3 = coords[triangle[2]]
        if delaunay_type == 'lines':
            lines.append([p_1, p_2, p_3, p_1])
        else:
            lines.append([[p_1, p_2, p_3, p_1]])

            
    if delaunay_type == 'lines':
        return str(geojson.MultiLineString(lines, precision=PRECISION))
    else:
        return str(geojson.MultiPolygon(lines, precision=PRECISION))

$$ LANGUAGE plpythonu;