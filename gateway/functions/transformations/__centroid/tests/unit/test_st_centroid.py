"""
Unit tests for ST_CENTROID

Tests the clouds library centroid helper functions.
"""

from test_utils.unit import load_function_module


def test_centroid_linestring_helper():
    """Test centroid_linestring helper function (from clouds)"""
    # Load function module from build directory
    imports = load_function_module(
        __file__, {"from_lib_module": {"center_lib.centroid": ["centroid_linestring"]}}
    )
    centroid_linestring = imports["centroid_linestring"]

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
    # Load function module from build directory
    imports = load_function_module(
        __file__, {"from_lib_module": {"center_lib.centroid": ["centroid_polygon"]}}
    )
    centroid_polygon = imports["centroid_polygon"]

    polygon1 = [[0, 0], [10, 0], [10, 10], [0, 10], [0, 0]]
    polygon2 = [[4, 4], [14, 2], [14, 8], [4, 6], [4, 4]]
    centroid1 = centroid_polygon(polygon1)
    centroid2 = centroid_polygon(polygon2)

    assert str(centroid1) == '{"coordinates": [5.0, 5.0], "type": "Point"}'
    assert (
        str(centroid2) == '{"coordinates": [9.833333333333334, 5.0], "type": "Point"}'
    )
