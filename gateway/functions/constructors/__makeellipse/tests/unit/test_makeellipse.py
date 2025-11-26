"""
Unit tests for __makeellipse function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate ST_MAKEELLIPSE
"""

# Copyright (c) 2025, CARTO

import geojson
import json
import os
import pytest

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["ellipse"],
        "from_lib_module": {"helper": ["load_geom", "get_coord"]},
    },
)
ellipse = imports["ellipse"]
load_geom = imports["load_geom"]
get_coord = imports["get_coord"]
lambda_handler = imports["lambda_handler"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Test the Lambda handler function"""

    def test_empty_event(self):
        """Test handler with empty event"""
        event = {"arguments": [], "num_records": 0}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 0
        assert result["results"] == []

    def test_single_valid_row(self):
        """Test handler with single valid row"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        event = {
            "arguments": [[center_json, "10", "5", "0", "kilometers", 64]],
            "num_records": 1,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

        # Verify the result is valid JSON
        ellipse_result = json.loads(result["results"][0])
        assert ellipse_result["type"] == "Polygon"

    def test_with_default_parameters(self):
        """Test handler with default angle, units, and steps"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        event = {"arguments": [[center_json, "10", "5"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is not None

    def test_with_partial_parameters(self):
        """Test handler with some optional parameters"""
        center_json = '{"type":"Point","coordinates":[0,0]}'

        # With angle only
        event = {"arguments": [[center_json, "10", "5", "45"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is not None

        # With angle and units
        event = {
            "arguments": [[center_json, "10", "5", "45", "miles"]],
            "num_records": 1,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is not None

    def test_null_center(self):
        """Test handler with null center"""
        event = {
            "arguments": [[None, "10", "5", "0", "kilometers", 64]],
            "num_records": 1,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_axes(self):
        """Test handler with null axes"""
        center_json = '{"type":"Point","coordinates":[0,0]}'

        # Null x axis
        event = {"arguments": [[center_json, None, "5"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is None

        # Null y axis
        event = {"arguments": [[center_json, "10", None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_angle(self):
        """Test handler with null angle"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        event = {
            "arguments": [[center_json, "10", "5", None, "kilometers", 64]],
            "num_records": 1,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        center1 = '{"type":"Point","coordinates":[0,0]}'
        center2 = '{"type":"Point","coordinates":[-74,40]}'
        event = {
            "arguments": [
                [center1, "10", "5", "0", "kilometers", 64],
                [center2, "20", "10", "45", "miles", 32],
                [None, "10", "5", "0", "kilometers", 64],
            ],
            "num_records": 3,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 3
        assert len(result["results"]) == 3
        assert result["results"][0] is not None
        assert result["results"][1] is not None
        assert result["results"][2] is None

    def test_malformed_row(self):
        """Test handler with malformed row"""
        event = {
            "arguments": [None, [], ["single_value"], ["a", "b"]],
            "num_records": 4,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert all(r is None for r in result["results"])

    def test_invalid_units_fails_batch(self):
        """Test handler with invalid units fails batch (FAIL_FAST mode)"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        event = {
            "arguments": [[center_json, "10", "5", "0", "invalid_unit", 64]],
            "num_records": 1,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        # With FAIL_FAST (default), invalid units fails the batch
        assert result["success"] is False
        assert "non valid units" in result["error_msg"]


# ============================================================================
# FUNCTION LOGIC TESTS
# ============================================================================


class TestHelperFunctions:
    """Test helper functions"""

    def test_load_geom(self):
        """Test loading geometry from JSON"""
        geom_json = '{"type":"Point","coordinates":[1,2]}'
        geom = load_geom(geom_json)
        assert geom["type"] == "Point"
        assert geom["coordinates"] == [1, 2]

    def test_get_coord_from_array(self):
        """Test getting coordinates from array"""
        coords = get_coord([1.5, 2.5])
        assert coords == [1.5, 2.5]

    def test_get_coord_from_geojson_point(self):
        """Test getting coordinates from geojson Point object"""
        import geojson

        point = geojson.Point([3, 4])
        coords = get_coord(point)
        assert coords == [3, 4]

    def test_get_coord_invalid(self):
        """Test get_coord with invalid input"""
        with pytest.raises(Exception, match="coord is required"):
            get_coord(None)


class TestEllipse:
    """Test the ellipse function"""

    def test_basic_ellipse_kilometers(self):
        """Test basic ellipse creation in kilometers"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        result_str = ellipse(
            center_json, 10, 5, {"units": "kilometers", "steps": 64, "angle": 0}
        )
        result = json.loads(result_str)

        assert result["type"] == "Polygon"
        assert len(result["coordinates"]) == 1
        # Should have 65 points (64 steps + closing point)
        assert len(result["coordinates"][0]) == 65
        # First and last point should be the same (closed polygon)
        assert result["coordinates"][0][0] == result["coordinates"][0][-1]

    def test_ellipse_with_angle(self):
        """Test ellipse with rotation angle"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        result_no_rotation = ellipse(
            center_json, 10, 5, {"units": "kilometers", "angle": 0}
        )
        result_rotated = ellipse(
            center_json, 10, 5, {"units": "kilometers", "angle": 45}
        )

        coords_no_rotation = json.loads(result_no_rotation)["coordinates"][0]
        coords_rotated = json.loads(result_rotated)["coordinates"][0]

        # Rotated ellipse should have different coordinates
        assert coords_no_rotation[0] != coords_rotated[0]

    def test_ellipse_different_units(self):
        """Test ellipse with different units"""
        center_json = '{"type":"Point","coordinates":[0,0]}'

        result_km = ellipse(center_json, 10, 5, {"units": "kilometers"})
        result_miles = ellipse(center_json, 10, 5, {"units": "miles"})

        # Different units should produce different sized ellipses
        assert result_km != result_miles

    def test_ellipse_degrees(self):
        """Test ellipse with degrees units"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        result_str = ellipse(
            center_json, 0.1, 0.05, {"units": "degrees", "steps": 64, "angle": 0}
        )
        result = json.loads(result_str)

        assert result["type"] == "Polygon"
        assert len(result["coordinates"][0]) == 65

    def test_ellipse_custom_steps(self):
        """Test ellipse with custom number of steps"""
        center_json = '{"type":"Point","coordinates":[0,0]}'

        result_few = ellipse(center_json, 10, 5, {"units": "kilometers", "steps": 8})
        result_many = ellipse(center_json, 10, 5, {"units": "kilometers", "steps": 128})

        coords_few = json.loads(result_few)["coordinates"][0]
        coords_many = json.loads(result_many)["coordinates"][0]

        # More steps should give more points
        assert len(coords_many) > len(coords_few)

    def test_circle_equal_axes(self):
        """Test that equal axes produce a circle-like shape"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        result_str = ellipse(center_json, 10, 10, {"units": "kilometers", "steps": 64})
        result = json.loads(result_str)

        assert result["type"] == "Polygon"
        # Circle should be symmetric

    def test_invalid_units(self):
        """Test ellipse with invalid units"""
        center_json = '{"type":"Point","coordinates":[0,0]}'
        with pytest.raises(Exception, match="non valid units"):
            ellipse(center_json, 10, 5, {"units": "invalid"})

    def test_ellipse_at_different_center(self):
        """Test ellipse centered at non-origin point"""
        center_json = '{"type":"Point","coordinates":[-74.0,40.7]}'
        result_str = ellipse(center_json, 10, 5, {"units": "kilometers"})
        result = json.loads(result_str)

        assert result["type"] == "Polygon"
        # Coordinates should be near the center point
        coords = result["coordinates"][0]
        avg_x = sum(c[0] for c in coords) / len(coords)
        avg_y = sum(c[1] for c in coords) / len(coords)
        assert abs(avg_x - (-74.0)) < 1
        assert abs(avg_y - 40.7) < 1

    def test_ellipse_from_clouds(self):
        """Test ellipse with exact fixture from clouds test"""
        here = os.path.dirname(__file__)
        with open(f"{here}/fixtures/ellipse_out.txt", "r") as fixture_file:
            lines = fixture_file.readlines()

        center_str = (
            '{"geometry": {"type": "Point", "coordinates": [-73.9385, 40.6643]}}'
        )
        result = ellipse(
            center=center_str,
            x_semi_axis=5,
            y_semi_axis=3,
            options={"angle": -30, "units": "miles", "steps": 20},
        )
        assert geojson.loads(result) == geojson.loads(lines[0].rstrip())
