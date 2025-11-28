"""
Unit tests for placekey_ash3 function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate placekey_ash3 .

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate placekey validation and H3 conversion
"""

# Copyright (c) 2025, CARTO

import json

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["placekey_ash3"],
        "from_lib_module": {
            "placekey": ["placekey_is_valid"],
        },
    },
)
placekey_ash3 = imports["placekey_ash3"]
lambda_handler = imports["lambda_handler"]
placekey_is_valid = imports["placekey_is_valid"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Test the Lambda handler interface.

    Validates that the function correctly implements the Redshift external
    function protocol for converting placekeys to H3 cell IDs.
    """

    def test_valid_placekey(self):
        """Test handler with valid placekey."""
        event = {"arguments": [["@c6z-c2g-dgk"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] == "8a62e9d08a1ffff"

    def test_invalid_placekey(self):
        """Test handler with invalid placekey."""
        event = {"arguments": [["@abc"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_input(self):
        """Test handler with null input."""
        event = {"arguments": [[None]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows."""
        event = {
            "arguments": [
                ["@c6z-c2g-dgk"],
                ["@63m-vc4-z75"],
                ["@abc"],
                [None],
            ]
        }
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert len(result["results"]) == 4
        assert result["results"][0] == "8a62e9d08a1ffff"
        assert result["results"][1] == "8a2a9c580577fff"
        assert result["results"][2] is None
        assert result["results"][3] is None


# ============================================================================
# FUNCTION LOGIC TESTS
# ============================================================================


class TestPlacekeyIsValid:
    """Test the placekey_is_valid helper function.

    Validates placekey format checking including what@ and address portions.
    """

    def test_valid_placekeys(self):
        """Test validation with valid placekeys."""
        assert placekey_is_valid("@c6z-c2g-dgk") is True
        assert placekey_is_valid("@63m-vc4-z75") is True
        assert placekey_is_valid("abc-234-xyz") is True
        assert placekey_is_valid("zzz@abc-234-xyz") is True

    def test_invalid_placekeys(self):
        """Test validation with invalid placekeys."""
        assert placekey_is_valid(None) is False
        assert placekey_is_valid("@abc") is False
        assert placekey_is_valid("abc-xyz") is False
        assert placekey_is_valid("abcxyz234") is False


class TestPlacekeyAsh3:
    """Test the placekey_ash3 main function.

    Validates conversion from placekey format to H3 cell ID string.
    """

    def test_valid_conversions(self):
        """Test conversion of valid placekeys to H3 cell IDs."""
        result = placekey_ash3("@c6z-c2g-dgk")
        assert result == "8a62e9d08a1ffff"

        result = placekey_ash3("@63m-vc4-z75")
        assert result == "8a2a9c580577fff"

        result = placekey_ash3("@7qg-xf9-j5f")
        assert result == "8a3c9ea2bd4ffff"

    def test_invalid_placekey_returns_none(self):
        """Test that invalid placekeys return None."""
        assert placekey_ash3("@abc") is None
        assert placekey_ash3("abc-xyz") is None
        assert placekey_ash3("abcxyz234") is None
