"""
Unit tests for ST_DESTINATION

Basic unit tests for destination function from clouds library.
"""


def test_st_destination_basic():
    """Test ST_DESTINATION basic functionality"""
    import sys
    import os

    lib_path = os.path.join(os.path.dirname(__file__), "../../code/lambda/python/lib")
    sys.path.insert(0, os.path.abspath(lib_path))

    from destination import destination
    import geojson

    # Test basic destination calculation
    point = geojson.Point((0, 0))
    result = destination(point, 100, 0, "kilometers")

    assert result is not None
    assert result.type == "Point"
    # Should have moved north
    assert result.coordinates[1] > 0
