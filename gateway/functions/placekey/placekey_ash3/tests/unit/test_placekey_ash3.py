"""
Unit tests for PLACEKEY_ASH3 function
"""

from test_utils.unit import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        "from_lib": ["placekey_ash3"],
        "from_lib_module": {"placekey": ["placekey_is_valid"]},
    },
)

placekey_ash3 = imports["placekey_ash3"]
placekey_is_valid = imports["placekey_is_valid"]
lambda_handler = imports["lambda_handler"]


class TestPlacekeyLibrary:
    """Test the placekey library functions"""

    def test_placekey_is_valid_true(self):
        """Test valid placekeys"""
        assert placekey_is_valid("@c6z-c2g-dgk") is True
        assert placekey_is_valid("@63m-vc4-z75") is True
        assert placekey_is_valid("abc-234-xyz") is True
        assert placekey_is_valid("zzz@abc-234-xyz") is True

    def test_placekey_is_valid_false(self):
        """Test invalid placekeys"""
        assert placekey_is_valid(None) is False
        assert placekey_is_valid("@abc") is False
        assert placekey_is_valid("abc-xyz") is False
        assert placekey_is_valid("abcxyz234") is False


class TestPlacekeyAsh3:
    """Test the placekey_ash3 function"""

    def test_valid_conversions(self):
        """Test valid placekey to H3 conversions"""
        result = placekey_ash3("@c6z-c2g-dgk")
        assert result == "8a62e9d08a1ffff"

        result = placekey_ash3("@63m-vc4-z75")
        assert result == "8a2a9c580577fff"

        result = placekey_ash3("@7qg-xf9-j5f")
        assert result == "8a3c9ea2bd4ffff"

    def test_invalid_placekey_returns_none(self):
        """Test that invalid placekeys return None"""
        assert placekey_ash3("@abc") is None
        assert placekey_ash3("abc-xyz") is None
        assert placekey_ash3("abcxyz234") is None


class TestLambdaHandler:
    """Test the Lambda handler function"""

    def test_valid_placekey(self):
        """Test handler with valid placekey"""
        import json

        event = {"arguments": [["@c6z-c2g-dgk"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] == "8a62e9d08a1ffff"

    def test_invalid_placekey(self):
        """Test handler with invalid placekey"""
        import json

        event = {"arguments": [["@abc"]]}
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
