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

    from test_utils.unit import load_function_module
    import geojson

    # Load function module from build directory
    imports = load_function_module(__file__, {"from_lib": ["great_circle"]})
    great_circle = imports["great_circle"]

    # Test basic great circle calculation
    start = geojson.Point((0, 0))
    end = geojson.Point((10, 10))
    result = great_circle(start, end, 25)

    assert result is not None
    assert result.type == "LineString"
    assert len(result.coordinates) == 25
