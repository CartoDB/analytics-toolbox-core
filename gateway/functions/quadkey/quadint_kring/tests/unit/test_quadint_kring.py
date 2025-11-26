"""
Unit tests for quadint_kring function.

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

    def test_quadint_kring_basic(self):
        """Test basic kring calculation"""
        # Size 0 should return only the origin
        event = {"arguments": [[162, 0]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 1
        assert kring[0] == 162

    def test_quadint_kring_size_1(self):
        """Test kring with size 1 - verify actual expected values"""
        # Size 1 should return 9 cells (3x3 grid)
        # Expected values from original test: [130, 162, 194, 2, 258, 290, 322, 34, 66]
        event = {"arguments": [[162, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 9  # (2*1+1)^2

        # Verify expected members (order may vary)
        expected = {130, 162, 194, 2, 258, 290, 322, 34, 66}
        assert set(kring) == expected

    def test_quadint_kring_size_2(self):
        """Test kring with size 2 - verify actual expected values"""
        # Size 2 should return 25 cells (5x5 grid)
        # Test with quadint 12070922
        event = {"arguments": [[12070922, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 25  # (2*2+1)^2

        # Verify expected members from original test
        expected = {
            12005322,
            12005354,
            12005386,
            12005418,
            12005450,
            12038090,
            12038122,
            12038154,
            12038186,
            12038218,
            12070858,
            12070890,
            12070922,
            12070954,
            12070986,
            12103626,
            12103658,
            12103690,
            12103722,
            12103754,
            12136394,
            12136426,
            12136458,
            12136490,
            12136522,
        }
        assert set(kring) == expected

    def test_quadint_kring_with_another_quadint(self):
        """Test kring with size 1 for different quadint"""
        # Test with quadint 12070922
        event = {"arguments": [[12070922, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 9

        # Verify expected members from original test
        expected = {
            12038122,
            12038154,
            12038186,
            12070890,
            12070922,
            12070954,
            12103658,
            12103690,
            12103722,
        }
        assert set(kring) == expected

    def test_quadint_kring_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Invalid input" in result["error_msg"]

    def test_quadint_kring_invalid_size(self):
        """Test invalid size"""
        event = {"arguments": [[162, -1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Invalid input" in result["error_msg"]
