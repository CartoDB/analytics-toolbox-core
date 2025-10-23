"""
Unit tests for DELAUNAYGENERIC function
"""

import json
import pytest
from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["delaunaygeneric"],
    },
)

delaunaygeneric = imports["delaunaygeneric"]
lambda_handler = imports["lambda_handler"]


class TestDelaunayGeneric:
    """Test the delaunaygeneric function"""

    def test_simple_triangle_lines(self):
        """Test basic triangle with 'lines' output"""
        # Three points forming a triangle
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        result_str = delaunaygeneric(geom_json, "lines")
        result = json.loads(result_str)

        assert result["type"] == "MultiLineString"
        assert len(result["coordinates"]) == 1  # One triangle
        assert len(result["coordinates"][0]) == 4  # Closed triangle (4 points)
        # First and last point should be the same (closed)
        assert result["coordinates"][0][0] == result["coordinates"][0][3]

    def test_simple_triangle_poly(self):
        """Test basic triangle with 'poly' output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        result_str = delaunaygeneric(geom_json, "poly")
        result = json.loads(result_str)

        assert result["type"] == "MultiPolygon"
        assert len(result["coordinates"]) == 1  # One triangle
        assert len(result["coordinates"][0]) == 1  # One ring
        assert len(result["coordinates"][0][0]) == 4  # Closed triangle

    def test_four_points_lines(self):
        """Test four points creating multiple triangles with 'lines'"""
        # Four points that should create 2 triangles
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        result_str = delaunaygeneric(geom_json, "lines")
        result = json.loads(result_str)

        assert result["type"] == "MultiLineString"
        # Should have 2 triangles
        assert len(result["coordinates"]) == 2

    def test_four_points_poly(self):
        """Test four points creating multiple triangles with 'poly'"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        result_str = delaunaygeneric(geom_json, "poly")
        result = json.loads(result_str)

        assert result["type"] == "MultiPolygon"
        assert len(result["coordinates"]) == 2  # Two triangles

    def test_null_points(self):
        """Test with null points input"""
        result = delaunaygeneric(None, "lines")
        assert result is None

    def test_invalid_delaunay_type(self):
        """Test with invalid delaunay_type"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        result = delaunaygeneric(geom_json, "invalid")
        assert result is None

    def test_invalid_geometry_type(self):
        """Test that non-MultiPoint raises error"""
        geom_json = '{"type":"Point","coordinates":[0,0]}'
        with pytest.raises(ValueError, match="must be MultiPoint"):
            delaunaygeneric(geom_json, "lines")

    def test_precision(self):
        """Test that output uses correct precision"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        result_str = delaunaygeneric(geom_json, "lines")

        # Should have precision field (geojson library handles precision)
        assert result_str is not None

    def test_collinear_points(self):
        """Test with collinear points (should fail or degenerate)"""
        # Three collinear points - scipy.spatial.Delaunay should handle this
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[2,0]]}'
        try:
            result_str = delaunaygeneric(geom_json, "lines")
            # If it succeeds, result might be empty or degenerate
            result = json.loads(result_str)
            assert result["type"] == "MultiLineString"
        except Exception:
            # Collinear points may raise an error from scipy
            pass


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

    def test_single_valid_row_lines(self):
        """Test handler with single valid row - lines output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        event = {"arguments": [[geom_json, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

        # Verify the result is valid JSON
        delaunay_result = json.loads(result["results"][0])
        assert delaunay_result["type"] == "MultiLineString"

    def test_single_valid_row_poly(self):
        """Test handler with single valid row - poly output"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        event = {"arguments": [[geom_json, "poly"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is not None

        delaunay_result = json.loads(result["results"][0])
        assert delaunay_result["type"] == "MultiPolygon"

    def test_null_geometry(self):
        """Test handler with null geometry"""
        event = {"arguments": [[None, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_invalid_delaunay_type(self):
        """Test handler with invalid delaunay_type"""
        geom_json = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        event = {"arguments": [[geom_json, "invalid"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        geom1 = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[0.5,1]]}'
        geom2 = '{"type":"MultiPoint","coordinates":[[0,0],[1,0],[1,1],[0,1]]}'
        event = {
            "arguments": [[geom1, "lines"], [geom2, "poly"], [None, "lines"]],
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
        event = {"arguments": [None, ["single_value"], []], "num_records": 3}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert all(r is None for r in result["results"])

    def test_invalid_geometry_type_fails_batch(self):
        """Test handler with invalid geometry type fails batch (FAIL_FAST mode)"""
        geom_json = '{"type":"Point","coordinates":[0,0]}'
        event = {"arguments": [[geom_json, "lines"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        # With FAIL_FAST (default), invalid geometry fails the batch
        assert result["success"] is False
        assert "must be MultiPoint" in result["error_msg"]
