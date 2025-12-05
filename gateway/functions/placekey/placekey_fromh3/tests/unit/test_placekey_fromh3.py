"""
Unit tests for placekey_fromh3 function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate placekey_fromh3 .

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate H3 validation and placekey conversion
"""

# Copyright (c) 2025, CARTO

import json

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["placekey_fromh3"],
        "from_lib_module": {
            "placekey": ["h3_is_valid"],
        },
    },
)
placekey_fromh3 = imports["placekey_fromh3"]
lambda_handler = imports["lambda_handler"]
h3_is_valid = imports["h3_is_valid"]

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================


class TestLambdaHandler:
    """Test the Lambda handler interface.

    Validates that the function correctly implements the Redshift external
    function protocol for converting H3 cell IDs to placekeys.
    """

    def test_valid_h3(self):
        """Test handler with valid H3 cell ID."""
        event = {"arguments": [["847b59dffffffff"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] == "@ff7-swh-m49"

    def test_invalid_h3(self):
        """Test handler with invalid H3 cell ID."""
        event = {"arguments": [["ff283473fffffff"]]}
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
                ["847b59dffffffff"],
                ["8a2a9c580577fff"],
                ["ff283473fffffff"],
                [None],
            ]
        }
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)

        assert result["success"] is True
        assert len(result["results"]) == 4
        assert result["results"][0] == "@ff7-swh-m49"
        assert result["results"][1] == "@63m-vc4-z75"
        assert result["results"][2] is None
        assert result["results"][3] is None


# ============================================================================
# FUNCTION LOGIC TESTS
# ============================================================================


class TestH3IsValid:
    """Test the h3_is_valid helper function.

    Validates H3 cell ID format checking.
    """

    def test_valid_h3_indices(self):
        """Test validation with valid H3 cell IDs."""
        assert h3_is_valid("847b59dffffffff") is True
        assert h3_is_valid("8a2a9c580577fff") is True

    def test_invalid_h3_indices(self):
        """Test validation with invalid H3 cell IDs."""
        assert h3_is_valid("ff283473fffffff") is False
        assert h3_is_valid("invalid") is False


class TestPlacekeyFromh3:
    """Test the placekey_fromh3 main function.

    Validates conversion from H3 cell ID string to placekey format.
    """

    def test_valid_conversions(self):
        """Test conversion of valid H3 cell IDs to placekeys."""
        result = placekey_fromh3("847b59dffffffff")
        assert result == "@ff7-swh-m49"

        result = placekey_fromh3("8a2a9c580577fff")
        assert result == "@63m-vc4-z75"

        result = placekey_fromh3("8a3c9ea2bd4ffff")
        assert result == "@7qg-xf9-j5f"

    def test_invalid_h3_returns_none(self):
        """Test that invalid H3 cell IDs return None."""
        assert placekey_fromh3("ff283473fffffff") is None
        assert placekey_fromh3("invalid") is None
