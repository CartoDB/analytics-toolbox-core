from ._version import __version__  # noqa


def voronoi_generic(geog, bbox, voronoi_type):
    from voronoi import voronoi_generic

    return voronoi_generic(geog, bbox, voronoi_type)


def clip_segment_bbox(linestring, bottom_left, upper_right):
    from voronoi import clip_segment_bbox

    return clip_segment_bbox(linestring, bottom_left, upper_right)

def polygon_polygon_intersection(poly1, poly2):
    from voronoi import polygon_polygon_intersection

    return polygon_polygon_intersection(poly1, poly2)
