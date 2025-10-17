"""Unit tests for QUADINT_TOPARENT function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_toparent_basic(self):
        """Test parent calculation"""
        # At z=5, get parent at z=4
        event = {"arguments": [[15685, 4]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert isinstance(result["results"][0], int)

    def test_quadint_toparent_multiple_levels(self):
        """Test parent at different levels"""
        # At z=10, get parent at z=5
        event = {"arguments": [[6556810, 5], [6556810, 9]], "num_records": 2}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 2
        assert isinstance(result["results"][0], int)
        assert isinstance(result["results"][1], int)

    def test_quadint_toparent_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_toparent_invalid_resolution(self):
        """Test invalid resolution - must be less than current zoom"""
        event = {"arguments": [[642, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong resolution" in result["error_msg"]

        event = {"arguments": [[642, -1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong resolution" in result["error_msg"]
