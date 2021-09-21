# Copyright (c) 2014, Morgan Herlocker (JavaScript implementation)
# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from ._version import __version__ # noqa
from center_mean import center_mean


#def buffer(geog, radius, bbox, units='kilometers', steps=8):
#
#    units_mapping = {
#        'miles': 'mi',
#        'kilometers': 'km',
#        'meters': 'm',
#        'degrees': 'degrees',
#    }
#
#    # validation
#    if geog is None:
#        raise Exception('geog is required')
#    if radius is None:
#        raise Exception('radius is required')
#    if units not in units_mapping:
#        raise Exception('non valid units')
#    if steps <= 0:
#        raise Exception('steps must be greater than 0')
#    
#    # Take the type of geometry
##    if geog.type == 'GeometryCollection' or geog.type == 'FeatureCollection':
##        return str(geog)
##
##    return buffer_feature(geog, radius, units, steps)
#
#    from helper import center_bbox
#    return center_bbox(bbox)