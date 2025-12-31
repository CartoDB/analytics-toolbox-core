"""
Unit tests for s2_totoken function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
"""

# Copyright (c) 2025, CARTO

import json

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(__file__, {})
lambda_handler = imports["lambda_handler"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_lambda_handler_basic(self):
        """Test Lambda handler with basic input"""
        # Use a known S2 cell ID
        cell_id = -7843177080740118528
        event = {"arguments": [[cell_id]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert isinstance(result["results"][0], str)
        assert len(result["results"][0]) > 0

    def test_lambda_handler_null_inputs(self):
        """Test Lambda handler with null inputs raises exception"""
        event = {"arguments": [[None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]
