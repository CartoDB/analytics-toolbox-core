# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO

from .spline import Spline
from .helper import load_geom, PRECISION


def bezier_spline(line, resolution=10000, sharpness=0.85):
    """
    Takes a line and returns a curved version by applying a Bezier spline algorithm.

    Args:
        line: LineString GeoJSON geometry string
        resolution: Time in milliseconds between points
        sharpness: Measure of how curvy the path should be between splines (0-1)

    Returns:
        Curved LineString as GeoJSON string
    """
    import geojson
    from math import floor

    coords = []
    points = []
    geom = load_geom(line)

    # Extract coordinates and convert to point dict format
    for c in geom["coordinates"]:
        points.append({"x": c[0], "y": c[1]})

    # Generate spline
    spline = Spline(points_data=points, resolution=resolution, sharpness=sharpness)

    # Sample points from spline
    i = 0
    while i < spline.duration:
        pos = spline.pos(i)
        if floor(i / 100) % 2 == 0:
            coords.append((pos["x"], pos["y"]))
        i = i + 10

    feature = geojson.Feature(geometry=geojson.LineString(coords, precision=PRECISION))
    return geojson.dumps(feature["geometry"])


__all__ = ["bezier_spline", "Spline", "load_geom", "PRECISION"]
