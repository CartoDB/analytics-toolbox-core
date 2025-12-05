"""
Unit tests for quadint_bbox function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
"""

# Copyright (c) 2025, CARTO

import json
import pytest

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_bbox_basic(self):
        """Test basic quadint bbox calculation"""
        # Test case from original test_quadkey.py
        event = {"arguments": [[162]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        bbox = json.loads(result["results"][0])
        assert bbox == pytest.approx([-90, 0, 0, 66.51326044311186])

    def test_quadint_bbox_multiple(self):
        """Test multiple bbox calculations"""
        event = {
            "arguments": [[12070922], [791040491538], [12960460429066265]],
            "num_records": 3,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 3

        bbox1 = json.loads(result["results"][0])
        assert bbox1 == pytest.approx(
            [-45, 44.84029065139799, -44.6484375, 45.089035564831015]
        )

        bbox2 = json.loads(result["results"][1])
        assert bbox2 == pytest.approx(
            [-45, 44.999767019181284, -44.998626708984375, 45.000738078290674]
        )

        bbox3 = json.loads(result["results"][2])
        assert bbox3 == pytest.approx(
            [-45, 44.99999461263668, -44.99998927116394, 45.00000219906961]
        )

    def test_quadint_bbox_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_bbox_empty(self):
        """Test empty input handling"""
        event = {"arguments": [[]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]
