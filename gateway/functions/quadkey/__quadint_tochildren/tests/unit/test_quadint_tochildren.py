"""
Unit tests for __quadint_tochildren function.

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

    def test_quadint_tochildren_basic(self):
        """Test children calculation with expected values"""
        # Get children one level down (z=0 -> z=1)
        # quadint 0 at z=0 (root tile) should have 4 children at z=1
        event = {"arguments": [[0, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        children = json.loads(result["results"][0])
        assert isinstance(children, list)
        assert len(children) == 4  # One level down = 4 children
        # All should be integers
        assert all(isinstance(c, int) for c in children)
        # Expected children of root tile at z=1: [1, 65, 33, 97] (from fixtures)
        assert sorted(children) == sorted([1, 65, 33, 97])

    def test_quadint_tochildren_multiple_levels(self):
        """Test children at different resolution differences"""
        # z=0 -> z=2 (2 levels) should give 16 children (4^2)
        event = {"arguments": [[0, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        children = json.loads(result["results"][0])
        assert isinstance(children, list)
        assert len(children) == 16  # 4^2 = 16 children for 2 levels
        assert all(isinstance(c, int) for c in children)

        # z=0 -> z=5 (5 levels) should give 1024 children (4^5)
        event = {"arguments": [[0, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        children = json.loads(result["results"][0])
        assert len(children) == 1024  # 4^5 = 1024 children for 5 levels

    def test_quadint_tochildren_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 6]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_tochildren_invalid_resolution(self):
        """Test invalid resolution - must be greater than current zoom"""
        event = {"arguments": [[162, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong resolution" in result["error_msg"]
