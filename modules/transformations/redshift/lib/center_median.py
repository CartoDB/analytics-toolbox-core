# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2021, CARTO

# weiszfeld algorithm
from __future__ import division
import geojson
import math
from center_mean import center_mean
from helper import euclidean_distance

def numer_sum(first_median, coords):
    return 1/euclidean_distance(first_median, coords)

def denom_sum(first_median, coords):
    temp = 0.0
    for i in range(len(coords)):
        temp += 1/euclidean_distance(first_median, coords[i])
    return temp


def center_median(geog, n_iter):

    # validation
    if geog is None:
        raise Exception('geog is required')


    # Calculate mean center
    c_mean = list(geojson.utils.coords(center_mean(geog)))[0]

    # Calculate centroid of every feature
    coords = []
    if geog.type == 'GeometryCollection':
        for feature in geog.geometries:
            cent = center_mean(feature)
            coords.append(list(geojson.utils.coords(cent))[0])
    elif geog.type == 'MultiPoint' or geog.type == 'Point':
        coords = list(geojson.utils.coords(geog))
    else:
        raise Exception('unsupported geometry type ' + geog.type)
    
    # Minimize the median
    for i in range(n_iter):
        denom = denom_sum(c_mean, coords)
        next_x = 0.0
        next_y = 0.0

        for j in range(len(coords)):
           next_x += (coords[j][0] * numer_sum(c_mean,coords[j]))/denom
           next_y += (coords[j][1] * numer_sum(c_mean,coords[j]))/denom
        c_mean = [next_x,next_y]

    return geojson.Point((c_mean))
