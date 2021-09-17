from ._version import __version__ # noqa


def make_ellipse(center, x_semi_axis, y_semi_axis, options={}):
    from ellipse import ellipse

    return ellipse(center, x_semi_axis, y_semi_axis, options)


def bezier_spline(line, resolution=10000, sharpness=0.85):
    from bezier_spline import bezier_spline

    return bezier_spline(line, resolution, sharpness)
