"""
Unit tests for __centermean function.

This file contains:
- Function Logic Tests: Validate ST_CENTERMEAN

Tests the clouds library  remove_end_polygon_point
"""

# Copyright (c) 2025, CARTO

import geojson

from test_utils.unit import load_function_module

# ============================================================================
# FUNCTION LOGIC TESTS
# ============================================================================


def test_remove_end_polygon_point():
    """Test remove_end_polygon_point helper function (from shared library)"""
    # Load function module from build directory
    imports = load_function_module(__file__, {"from_lib": ["remove_end_polygon_point"]})
    remove_end_polygon_point = imports["remove_end_polygon_point"]

    feature1 = (
        '{"type":"Polygon","coordinates":[[[30,10],[40,40],[20,40],[10,20],[30,10]]]}'
    )
    feature2 = (
        '{"type":"Polygon","coordinates":[[[35,10],[45,45],[15,40],[10,20],[35,10]],'
        "[[20,30],[35,35],[30,20],[20,30]]]}"
    )
    feature3 = (
        '{"type":"MultiPolygon","coordinates":[[[[30,20],[45,40],[10,40],[30,20]]],'
        "[[[15,5],[40,10],[10,20],[5,10],[15,5]]]]}"
    )
    feature4 = (
        '{"type":"MultiPolygon","coordinates":[[[[40,40],[20,45],[45,30],[40,40]]],'
        "[[[20,35],[10,30],[10,10],[30,5],[45,20],[20,35]],[[30,20],[20,15],[20,25],"
        "[30,20]]]]}"
    )

    geojson1 = geojson.loads(feature1)
    geojson2 = geojson.loads(feature2)
    geojson3 = geojson.loads(feature3)
    geojson4 = geojson.loads(feature4)

    # Check that remove_end_polygon_point works correctly
    result1 = remove_end_polygon_point(geojson1.coordinates)
    assert len(result1) == 4
    assert result1[0] == (30, 10) or result1[0] == (30.0, 10.0)

    result2 = remove_end_polygon_point(geojson2.coordinates)
    assert len(result2) == 7

    result3 = remove_end_polygon_point(geojson3.coordinates)
    assert len(result3) == 7

    result4 = remove_end_polygon_point(geojson4.coordinates)
    assert len(result4) == 11
