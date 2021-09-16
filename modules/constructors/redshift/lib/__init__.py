__version__ = '1.0.0'


def make_ellipse(center, x_semi_axis, y_semi_axis, options={}):
    from ellipse import ellipse

    return ellipse(center, x_semi_axis, y_semi_axis, options)
