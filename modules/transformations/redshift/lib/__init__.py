from ._version import __version__  # noqa


def center_mean(geog):
    from center_lib import center_mean

    return center_mean(geog)


def center_median(geog, n_iter):
    from center_lib import center_median

    return center_median(geog, n_iter)


def centroid(geog, area_poly, length_line):
    from center_lib import centroid

    return centroid(geog, area_poly, length_line)


def great_circle(start_point, end_point, n_points):
    from great_circle import great_circle

    return great_circle(start_point, end_point, n_points)


def destination(geog, distance, bearing, units):
    from destination import destination

    return destination(geog, distance, bearing, units)
