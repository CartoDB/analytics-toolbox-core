"""
Unit tests for ST_CENTERMEDIAN

Basic unit tests for center_median function from clouds library.
"""


def test_st_centermedian_basic():
    """Test ST_CENTERMEDIAN basic functionality"""
    import sys
    import os

    lib_path = os.path.join(os.path.dirname(__file__), "../../code/lambda/python/lib")
    sys.path.insert(0, os.path.abspath(lib_path))

    from center_lib.center_median import center_median
    import geojson

    # Test with a simple polygon
    polygon = geojson.Polygon([[(0, 0), (10, 0), (10, 10), (0, 10), (0, 0)]])
    result = center_median(polygon, 10)

    assert result is not None
    assert result.type == "Point"
    # Result should be somewhere near the center
    assert 0 <= result.coordinates[0] <= 10
    assert 0 <= result.coordinates[1] <= 10
