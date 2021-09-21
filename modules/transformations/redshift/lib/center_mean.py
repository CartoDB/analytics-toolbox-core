# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

import geojson

def center_mean(geog):

    # validation
    if geog is None:
        raise Exception('geog is required')
    
    # Take the type of geometry
    coords = []
    if geog.type == 'GeometryCollection':
        coords = geog.geometries
    else:
        coords = geog
        
    sum_x = 0
    sum_y = 0
    total_features = 0
    for point in list(geojson.utils.coords(coords)):
        total_features+=1
        sum_x += point[0]
        sum_y += point[1]
    
    return str(geojson.Point((sum_x / total_features, sum_y / total_features)))