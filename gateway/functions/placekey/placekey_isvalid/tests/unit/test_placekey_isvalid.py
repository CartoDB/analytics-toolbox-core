"""
Unit tests for placekey_isvalid function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate placekey_isvalid .

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate placekey format validation
"""

# Copyright (c) 2025, CARTO

import json

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["placekey_isvalid"],
    },
)
placekey_isvalid = imports["placekey_isvalid"]
lambda_handler = imports["lambda_handler"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Test the Lambda handler interface.

    Validates that the function correctly implements the Redshift external
    function protocol for validating placekey format.
    """

    def test_valid_placekey(self):
        """Test handler with valid placekey."""
        event = {"arguments": [["abc-234-xyz"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is True

    def test_invalid_placekey(self):
        """Test handler with invalid placekey."""
        event = {"arguments": [["@abc"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is False

    def test_null_input(self):
        """Test handler with null input."""
        event = {"arguments": [[None]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is False

    def test_batch_processing(self):
        """Test handler with multiple rows."""
        event = {
            "arguments": [
                ["abc-234-xyz"],
                ["@abc-234-xyz"],
                ["@abc"],
                [None],
            ]
        }
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert len(result["results"]) == 4
        assert result["results"][0] is True
        assert result["results"][1] is True
        assert result["results"][2] is False
        assert result["results"][3] is False


# ============================================================================
# FUNCTION LOGIC TESTS
# ============================================================================


class TestPlacekeyIsvalid:
    """Test the placekey_isvalid main function.

    Validates placekey format checking including what@ and address portions,
    handling various valid and invalid formats.
    """

    def test_valid_placekeys(self):
        """Test validation returns True for valid placekeys."""
        assert placekey_isvalid("abc-234-xyz") is True
        assert placekey_isvalid("@abc-234-xyz") is True
        assert placekey_isvalid("bcd-2u4-xez") is True
        assert placekey_isvalid("zzz@abc-234-xyz") is True
        assert placekey_isvalid("222-zzz@abc-234-xyz") is True

    def test_invalid_placekeys(self):
        """Test validation returns False for invalid placekeys."""
        assert placekey_isvalid(None) is False
        assert placekey_isvalid("@abc") is False
        assert placekey_isvalid("abc-xyz") is False
        assert placekey_isvalid("abcxyz234") is False
        assert placekey_isvalid("abc@abc-234-xyz") is False
        assert placekey_isvalid("ebc-345@abc-234-xyz") is False
        assert placekey_isvalid("bcd-345@") is False
        assert placekey_isvalid("22-zzz@abc-234-xyz") is False
