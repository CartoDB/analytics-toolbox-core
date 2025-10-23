"""
Unit tests for ST_DESTINATION

Basic unit tests for destination function from clouds library.
"""

import geojson
from test_utils.unit import load_function_module


def test_st_destination_basic():
    """Test ST_DESTINATION basic functionality"""
    # Load function module from build directory
    imports = load_function_module(__file__, {"from_lib": ["destination"]})
    destination = imports["destination"]

    # Test basic destination calculation
    point = geojson.Point((0, 0))
    result = destination(point, 100, 0, "kilometers")

    assert result is not None
    assert result.type == "Point"
    # Should have moved north
    assert result.coordinates[1] > 0
