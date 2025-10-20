"""
Unit tests for ST_CENTERMEDIAN

Basic unit tests for center_median function from clouds library.
"""

import geojson
from test_utils.unit import load_function_module


def test_st_centermedian_basic():
    """Test ST_CENTERMEDIAN basic functionality"""
    # Load function module from build directory
    imports = load_function_module(__file__, {"from_lib": ["center_median"]})
    center_median = imports["center_median"]

    # Test with a simple polygon
    polygon = geojson.Polygon([[(0, 0), (10, 0), (10, 10), (0, 10), (0, 0)]])
    result = center_median(polygon, 10)

    assert result is not None
    assert result.type == "Point"
    # Result should be somewhere near the center
    assert 0 <= result.coordinates[0] <= 10
    assert 0 <= result.coordinates[1] <= 10
