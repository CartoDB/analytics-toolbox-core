"""
Unit tests for quadint_sibling function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
"""

# Copyright (c) 2025, CARTO

import json

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_sibling_roundtrip(self):
        """Test round-trip navigation"""
        quadint = 162

        # Navigate right -> up -> left -> down should return to start
        event = {"arguments": [[quadint, "right"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        right_quadint = result["results"][0]

        event = {"arguments": [[right_quadint, "up"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        up_quadint = result["results"][0]

        event = {"arguments": [[up_quadint, "left"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        left_quadint = result["results"][0]

        event = {"arguments": [[left_quadint, "down"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)
        assert result["success"] is True
        final_quadint = result["results"][0]

        assert final_quadint == quadint

    def test_quadint_sibling_directions(self):
        """Test all four directions"""
        event = {
            "arguments": [[162, "left"], [162, "right"], [162, "up"], [162, "down"]],
            "num_records": 4,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 4
        for i in range(4):
            assert isinstance(result["results"][i], int)
        # All should be unique
        assert len(set(result["results"])) == 4

    def test_quadint_sibling_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, "right"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_sibling_invalid_direction(self):
        """Test invalid direction"""
        event = {"arguments": [[162, "invalid"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong direction argument" in result["error_msg"]
