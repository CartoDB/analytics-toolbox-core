"""
Unit tests for __destination function.

This file contains:
- Function Logic Tests: Validate ST_DESTINATION

Basic unit tests for destination  from clouds library.
"""

# Copyright (c) 2025, CARTO

import geojson

from test_utils.unit import load_function_module

# ============================================================================
# FUNCTION LOGIC TESTS
# ============================================================================


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
