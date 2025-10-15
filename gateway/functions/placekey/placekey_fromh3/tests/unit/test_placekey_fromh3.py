"""
Unit tests for PLACEKEY_FROMH3 function
"""

from test_utils.unit import load_function_module

# Import shared library functions directly for testing
from placekey import h3_is_valid

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["placekey_fromh3"],
    },
)

placekey_fromh3 = imports["placekey_fromh3"]
lambda_handler = imports["lambda_handler"]


class TestH3Library:
    """Test the H3 library functions"""

    def test_h3_is_valid_true(self):
        """Test valid H3 indices"""
        assert h3_is_valid("847b59dffffffff") is True
        assert h3_is_valid("8a2a9c580577fff") is True

    def test_h3_is_valid_false(self):
        """Test invalid H3 indices"""
        assert h3_is_valid("ff283473fffffff") is False
        assert h3_is_valid("invalid") is False


class TestPlacekeyFromh3:
    """Test the placekey_fromh3 function"""

    def test_valid_conversions(self):
        """Test valid H3 to placekey conversions"""
        result = placekey_fromh3("847b59dffffffff")
        assert result == "@ff7-swh-m49"

        result = placekey_fromh3("8a2a9c580577fff")
        assert result == "@63m-vc4-z75"

        result = placekey_fromh3("8a3c9ea2bd4ffff")
        assert result == "@7qg-xf9-j5f"

    def test_invalid_h3_returns_none(self):
        """Test that invalid H3 indices return None"""
        assert placekey_fromh3("ff283473fffffff") is None
        assert placekey_fromh3("invalid") is None


class TestLambdaHandler:
    """Test the Lambda handler function"""

    def test_valid_h3(self):
        """Test handler with valid H3"""
        import json

        event = {"arguments": [["847b59dffffffff"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] == "@ff7-swh-m49"

    def test_invalid_h3(self):
        """Test handler with invalid H3"""
        import json

        event = {"arguments": [["ff283473fffffff"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_input(self):
        """Test handler with null input"""
        import json

        event = {"arguments": [[None]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        import json

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
