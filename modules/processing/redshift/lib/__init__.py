from ._version import __version__  # noqa

# from voronoi import voronoi_generic


def voronoi_generic(geog, voronoi_type):
    from voronoi import voronoi_generic

    return voronoi_generic(geog, voronoi_type)


def clip_line_bbox(linestring, bottom_left, upper_right):
    from voronoi import clip_line_bbox

    return clip_line_bbox(linestring, bottom_left, upper_right)
