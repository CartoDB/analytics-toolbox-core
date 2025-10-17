"""Unit tests for QUADINT_BOUNDARY function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_boundary_basic(self):
        """Test basic quadint boundary calculation"""
        event = {"arguments": [[162]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1

        geom = json.loads(result["results"][0])
        assert geom["type"] == "Polygon"
        assert len(geom["coordinates"]) == 1
        assert len(geom["coordinates"][0]) == 5  # Closed polygon

    def test_quadint_boundary_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_boundary_empty(self):
        """Test empty input handling"""
        event = {"arguments": [[]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]
