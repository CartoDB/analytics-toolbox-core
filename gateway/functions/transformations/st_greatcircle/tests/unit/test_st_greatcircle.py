"""
Unit tests for ST_GREATCIRCLE

Basic unit tests for great_circle function from clouds library.
"""

import pytest


def test_st_greatcircle_basic():
    """Test ST_GREATCIRCLE basic functionality"""
    # Check for pygc
    try:
        import pygc  # noqa: F401
    except ImportError:
        pytest.skip("pygc not available in test environment")

    import sys
    import os

    lib_path = os.path.join(os.path.dirname(__file__), "../../code/lambda/python/lib")
    sys.path.insert(0, os.path.abspath(lib_path))

    from great_circle import great_circle
    import geojson

    # Test basic great circle calculation
    start = geojson.Point((0, 0))
    end = geojson.Point((10, 10))
    result = great_circle(start, end, 25)

    assert result is not None
    assert result.type == "LineString"
    assert len(result.coordinates) == 25
