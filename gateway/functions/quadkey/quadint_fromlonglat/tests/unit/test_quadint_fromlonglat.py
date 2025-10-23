"""Unit tests for QUADINT_FROMLONGLAT function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_fromlonglat_basic(self):
        """Test basic quadint from lon/lat conversion"""
        event = {"arguments": [["0.0", "0.0", 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert isinstance(result["results"][0], int)
        assert result["results"][0] > 0

    def test_quadint_fromlonglat_different_resolutions(self):
        """Test at different resolutions"""
        event = {
            "arguments": [["-45.0", "45.0", 10], ["-45.0", "45.0", 15]],
            "num_records": 2,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 2
        assert isinstance(result["results"][0], int)
        assert isinstance(result["results"][1], int)

    def test_quadint_fromlonglat_clipping(self):
        """Test latitude clipping at poles"""
        event = {
            "arguments": [["0.0", "85.0", 5], ["0.0", "90.0", 5]],
            "num_records": 2,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 2
        # Both should produce valid results
        assert isinstance(result["results"][0], int)
        assert isinstance(result["results"][1], int)

    def test_quadint_fromlonglat_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, "0.0", 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_fromlonglat_invalid_zoom(self):
        """Test invalid zoom level"""
        event = {"arguments": [["0.0", "0.0", -1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong zoom" in result["error_msg"]

        event = {"arguments": [["0.0", "0.0", 30]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong zoom" in result["error_msg"]
