"""Unit tests for QUADINT_FROMQUADKEY function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_fromquadkey_basic(self):
        """Test basic quadkey to quadint conversion"""
        event = {"arguments": [["0"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert isinstance(result["results"][0], int)

    def test_quadint_fromquadkey_valid(self):
        """Test valid quadkey"""
        event = {"arguments": [["03"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert isinstance(result["results"][0], int)

    def test_quadint_fromquadkey_null(self):
        """Test NULL input handling - should raise exception"""
        event = {"arguments": [[None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_fromquadkey_empty_array(self):
        """Test empty array input handling - should raise exception"""
        event = {"arguments": [[]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_fromquadkey_empty_string(self):
        """Test empty string (valid quadkey for z=0, x=0, y=0)"""
        event = {"arguments": [[""]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert result["results"][0] == 0  # Empty quadkey = quadint 0
