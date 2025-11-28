# Copyright (c) 2021, CARTO
# https://en.wikipedia.org/wiki/Geometric_median

from __future__ import division
import geojson

from lib.transformations import PRECISION, euclidean_distance, center_mean


def numer_sum(first_median, coords):
    return 1 / euclidean_distance(first_median, coords)


def denom_sum(first_median, coords):
    temp = 0.0
    for i in range(len(coords)):
        temp += 1 / euclidean_distance(first_median, coords[i])
    return temp


def center_median(geom, n_iter):

    # Calculate mean center
    c_mean = list(geojson.utils.coords(center_mean(geom)))[0]

    # Calculate centroid of every feature
    coords = []
    if geom.type == "GeometryCollection":
        for feature in geom.geometries:
            cent = center_mean(feature)
            coords.append(list(geojson.utils.coords(cent))[0])
    else:
        coords = list(geojson.utils.coords(geom))

    # Minimize the median
    for i in range(n_iter):
        denom = denom_sum(c_mean, coords)
        next_x = 0.0
        next_y = 0.0

        for j in range(len(coords)):
            next_x += (coords[j][0] * numer_sum(c_mean, coords[j])) / denom
            next_y += (coords[j][1] * numer_sum(c_mean, coords[j])) / denom
        c_mean = [next_x, next_y]

    return geojson.Point((c_mean), precision=PRECISION)
