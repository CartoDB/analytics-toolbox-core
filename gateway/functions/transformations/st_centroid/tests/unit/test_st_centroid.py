"""
Unit tests for ST_CENTROID

Tests the clouds library centroid helper functions.
"""


def test_centroid_linestring_helper():
    """Test centroid_linestring helper function (from clouds)"""
    import sys
    import os

    lib_path = os.path.join(os.path.dirname(__file__), "../../code/lambda/python/lib")
    sys.path.insert(0, os.path.abspath(lib_path))

    from center_lib.centroid import centroid_linestring

    linestring1 = [[0, 0], [10, 0], [10, 10]]
    linestring2 = [[4, 4], [14, 2], [14, 8]]
    centroid1 = centroid_linestring(linestring1)
    centroid2 = centroid_linestring(linestring2)

    assert str(centroid1) == '{"coordinates": [7.5, 2.5], "type": "Point"}'
    assert (
        str(centroid2)
        == '{"coordinates": [10.852076041405398, 3.740830416562159], "type": "Point"}'
    )


def test_centroid_polygon_helper():
    """Test centroid_polygon helper function (from clouds)"""
    import sys
    import os

    lib_path = os.path.join(os.path.dirname(__file__), "../../code/lambda/python/lib")
    sys.path.insert(0, os.path.abspath(lib_path))

    from center_lib.centroid import centroid_polygon

    polygon1 = [[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]
    polygon2 = [[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]
    centroid1 = centroid_polygon(polygon1)
    centroid2 = centroid_polygon(polygon2)

    assert str(centroid1) == '{"coordinates": [5.0, 5.0], "type": "Point"}'
    assert (
        str(centroid2) == '{"coordinates": [9.833333333333334, 5.0], "type": "Point"}'
    )
