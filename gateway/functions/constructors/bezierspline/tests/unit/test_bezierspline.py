"""
Unit tests for ST_BEZIERSPLINE function
"""

import json
from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["Spline", "bezier_spline"],
    },
)

Spline = imports["Spline"]
bezier_spline = imports["bezier_spline"]
lambda_handler = imports["lambda_handler"]


class TestSpline:
    """Test the Spline class"""

    def test_simple_spline(self):
        """Test basic spline creation"""
        points = [{"x": 0, "y": 0}, {"x": 1, "y": 1}, {"x": 2, "y": 0}]
        spline = Spline(points_data=points, resolution=1000, sharpness=0.85)

        assert spline.length == 3
        assert len(spline.centers) == 2
        assert len(spline.controls) == 3

    def test_spline_position(self):
        """Test getting position on spline"""
        points = [{"x": 0, "y": 0}, {"x": 10, "y": 10}]
        spline = Spline(points_data=points, resolution=1000, sharpness=0.85)

        # Position at start
        pos_start = spline.pos(0)
        assert pos_start["x"] == 0
        assert pos_start["y"] == 0

        # Position at end
        pos_end = spline.pos(1000)
        assert pos_end["x"] == 10
        assert pos_end["y"] == 10

    def test_spline_with_z_coordinate(self):
        """Test spline with explicit z coordinate"""
        points = [{"x": 0, "y": 0, "z": 5}, {"x": 1, "y": 1, "z": 10}]
        spline = Spline(points_data=points)

        assert spline.points[0]["z"] == 5
        assert spline.points[1]["z"] == 10


class TestBezierSpline:
    """Test the bezier_spline function"""

    def test_basic_linestring(self):
        """Test basic linestring spline"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'
        result_str = bezier_spline(line_json)
        result = json.loads(result_str)

        assert result["type"] == "LineString"
        assert isinstance(result["coordinates"], list)
        assert len(result["coordinates"]) > 3  # Should have more points than input

    def test_straight_line(self):
        """Test spline on straight line"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[5,5],[10,10]]}'
        result_str = bezier_spline(line_json)
        result = json.loads(result_str)

        assert result["type"] == "LineString"
        assert len(result["coordinates"]) > 0

    def test_custom_resolution(self):
        """Test with custom resolution"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'

        # Lower resolution should give fewer points
        result_low = bezier_spline(line_json, resolution=100)
        result_high = bezier_spline(line_json, resolution=10000)

        coords_low = json.loads(result_low)["coordinates"]
        coords_high = json.loads(result_high)["coordinates"]

        # Higher resolution should generally produce more points
        assert len(coords_high) >= len(coords_low)

    def test_custom_sharpness(self):
        """Test with different sharpness values"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0],[3,1]]}'

        # Different sharpness should produce different curves
        result_sharp = bezier_spline(line_json, sharpness=0.1)
        result_smooth = bezier_spline(line_json, sharpness=0.9)

        assert result_sharp != result_smooth

    def test_two_point_line(self):
        """Test with minimum two points"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[10,10]]}'
        result_str = bezier_spline(line_json)
        result = json.loads(result_str)

        assert result["type"] == "LineString"
        assert len(result["coordinates"]) >= 2


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
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'
        event = {"arguments": [[line_json, 10000, 0.85]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

        # Verify the result is valid JSON
        spline_result = json.loads(result["results"][0])
        assert spline_result["type"] == "LineString"

    def test_with_default_parameters(self):
        """Test handler with default resolution and sharpness"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'
        event = {"arguments": [[line_json]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is not None

    def test_null_linestring(self):
        """Test handler with null linestring"""
        event = {"arguments": [[None, 10000, 0.85]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_resolution(self):
        """Test handler with null resolution"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'
        event = {"arguments": [[line_json, None, 0.85]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_sharpness(self):
        """Test handler with null sharpness"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'
        event = {"arguments": [[line_json, 10000, None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        line1 = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'
        line2 = '{"type":"LineString","coordinates":[[0,0],[5,5]]}'
        event = {
            "arguments": [
                [line1, 10000, 0.85],
                [line2, 5000, 0.5],
                [None, 10000, 0.85],
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
        """Test handler with malformed rows (nulls and empty)"""
        event = {"arguments": [None, []], "num_records": 2}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert all(r is None for r in result["results"])

    def test_partial_parameters(self):
        """Test handler with only some parameters"""
        line_json = '{"type":"LineString","coordinates":[[0,0],[1,1],[2,0]]}'

        # Only linestring and resolution
        event = {"arguments": [[line_json, 5000]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is not None
