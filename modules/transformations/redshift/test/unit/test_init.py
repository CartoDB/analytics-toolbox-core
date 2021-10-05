from lib import transformationsLib
from lib._version import __version__


def test_init():
    assert transformationsLib.__version__ == __version__
    assert hasattr(transformationsLib, 'center_mean')
    assert hasattr(transformationsLib, 'center_median')
    assert hasattr(transformationsLib, 'centroid')
    assert hasattr(transformationsLib, 'destination')
    assert hasattr(transformationsLib, 'great_circle')


def test_centroid_linestring():
    linestring1 = [[0, 0], [10, 0], [10, 10]]
    linestring2 = [[4, 4], [14, 2], [14, 8]]
    centroid1 = transformationsLib.centroid_linestring(linestring1)
    centroid2 = transformationsLib.centroid_linestring(linestring2)

    assert str(centroid1) == '{"coordinates": [7.5, 2.5], "type": "Point"}'
    assert str(centroid2) == '{"coordinates": [10.852076, 3.74083], "type": "Point"}'


def test_centroid_polygon():
    polygon1 = [[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]
    polygon2 = [[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]
    centroid1 = transformationsLib.centroid_polygon(polygon1)
    centroid2 = transformationsLib.centroid_polygon(polygon2)

    assert str(centroid1) == '{"coordinates": [5.0, 5.0], "type": "Point"}'
    assert str(centroid2) == '{"coordinates": [9.833333, 5.0], "type": "Point"}'
