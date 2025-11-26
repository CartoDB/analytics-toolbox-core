"""
Unit tests for quadint_toparent function.

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

    def test_quadint_toparent_basic(self):
        """Test parent calculation with expected values"""
        # Test with quadint 1 (z=1) - get parent at z=0
        # quadint 1 is a child of root (quadint 0), so parent should be 0
        event = {"arguments": [[1, 0]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        parent = result["results"][0]
        assert isinstance(parent, int)
        assert parent == 0  # Parent of quadint 1 at z=0 is root (0)

    def test_quadint_toparent_multiple_levels(self):
        """Test parent at different levels"""
        # Test with children from fixture line 10:
        # [20992010,21024778,20992042,21024810] at z=10
        # These are children of parent at z=9
        # Going from z=10 to z=9 (up 1 level)
        event = {"arguments": [[20992010, 9]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        parent_z9 = result["results"][0]
        assert isinstance(parent_z9, int)

        # Now test going up multiple levels: z=10 to z=7 (up 3 levels)
        event = {"arguments": [[20992010, 7]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        parent_z7 = result["results"][0]
        assert isinstance(parent_z7, int)
        # Parent at z=7 should be smaller than parent at z=9
        assert parent_z7 < parent_z9

    def test_quadint_toparent_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 5]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_toparent_invalid_resolution(self):
        """Test invalid resolution - must be less than current zoom"""
        # Test requesting parent at same or higher zoom
        # (quadint 1 is at z=1, can't get parent at z=1 or z=2)
        event = {"arguments": [[1, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong resolution" in result["error_msg"]

        # Test negative resolution
        event = {"arguments": [[1, -1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong resolution" in result["error_msg"]
