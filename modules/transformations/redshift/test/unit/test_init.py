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
    assert (
        str(centroid2)
        == '{"coordinates": [10.852076041405398, 3.740830416562159], "type": "Point"}'
    )


def test_centroid_polygon():
    polygon1 = [[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]
    polygon2 = [[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]
    centroid1 = transformationsLib.centroid_polygon(polygon1)
    centroid2 = transformationsLib.centroid_polygon(polygon2)

    assert str(centroid1) == '{"coordinates": [5.0, 5.0], "type": "Point"}'
    assert (
        str(centroid2) == '{"coordinates": [9.833333333333334, 5.0], "type": "Point"}'
    )


def test_remove_end_polygon_point():
    import geojson

    feature1 = (
        '{"type":"Polygon","coordinates":[[[30,10],[40,40],[20,40],[10,20],[30,10]]]}'
    )
    feature2 = (
        '{"type":"Polygon","coordinates":[[[35,10],[45,45],[15,40],[10,20],[35,10]],'
        '[[20,30],[35,35],[30,20],[20,30]]]}'
    )
    feature3 = (
        '{"type":"MultiPolygon","coordinates":[[[[30,20],[45,40],[10,40],[30,20]]],'
        '[[[15,5],[40,10],[10,20],[5,10],[15,5]]]]}'
    )
    feature4 = (
        '{"type":"MultiPolygon","coordinates":[[[[40,40],[20,45],[45,30],[40,40]]],'
        '[[[20,35],[10,30],[10,10],[30,5],[45,20],[20,35]],[[30,20],[20,15],[20,25],'
        '[30,20]]]]}'
    )

    geojson1 = geojson.loads(feature1)
    geojson2 = geojson.loads(feature2)
    geojson3 = geojson.loads(feature3)
    geojson4 = geojson.loads(feature4)

    assert (
        str(transformationsLib.remove_end_polygon_point(geojson1.coordinates))
        == '[(30.0, 10.0), (40.0, 40.0), (20.0, 40.0), (10.0, 20.0)]'
    )
    assert (
        str(transformationsLib.remove_end_polygon_point(geojson2.coordinates))
        == '[(35.0, 10.0), (45.0, 45.0), (15.0, 40.0), (10.0, 20.0), (20.0, 30.0), '
        '(35.0, 35.0), (30.0, 20.0)]'
    )
    assert (
        str(transformationsLib.remove_end_polygon_point(geojson3.coordinates))
        == '[(30.0, 20.0), (45.0, 40.0), (10.0, 40.0), (15.0, 5.0), (40.0, 10.0), '
        '(10.0, 20.0), (5.0, 10.0)]'
    )
    assert (
        str(transformationsLib.remove_end_polygon_point(geojson4.coordinates))
        == '[(40.0, 40.0), (20.0, 45.0), (45.0, 30.0), (20.0, 35.0), (10.0, 30.0), '
        '(10.0, 10.0), (30.0, 5.0), (45.0, 20.0), (30.0, 20.0), (20.0, 15.0), '
        '(20.0, 25.0)]'
    )
