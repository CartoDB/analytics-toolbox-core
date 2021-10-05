from lib import processingLib
from lib._version import __version__


def test_init():
    assert processingLib.__version__ == __version__
    assert hasattr(processingLib, 'voronoi_generic')


def test_check_polygon_intersection():
    polygon1 = [[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]
    polygon2 = [[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]
    intersection1 = processingLib.polygon_polygon_intersection(polygon1, polygon2)
    polygon1 = [[0, 0], [20, 0], [20, 20], [0, 20], [0, 0]]
    intersection2 = processingLib.polygon_polygon_intersection(polygon1, polygon2)
    polygon2 = [[20, 0], [40, 0], [40, 20], [0, 40], [0, 0]]
    intersection3 = processingLib.polygon_polygon_intersection(polygon1, polygon2)

    assert str(intersection1) == '[[4, 4], [10.0, 2.8], [10.0, 7.2], [4, 6], [4, 4]]'
    assert str(intersection2) == '[[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]'
    assert str(intersection3) == '[]'


def test_check_clip_segment_bbox():
    linestring = [[2, 2], [12, 2]]
    bottom_left = [0, 0]
    upper_right = [10, 10]
    intersection1 = processingLib.clip_segment_bbox(
        linestring, bottom_left, upper_right
    )
    linestring = [[12, 0], [16, 4]]
    intersection2 = processingLib.clip_segment_bbox(
        linestring, bottom_left, upper_right
    )

    assert str(intersection1) == '[[2, 2], [10.0, 2.0]]'
    assert str(intersection2) == '[]'
