"""
Unit tests for PLACEKEY_ISVALID function
"""

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


class TestPlacekeyIsvalid:
    """Test the placekey_isvalid function"""

    def test_valid_placekeys(self):
        """Test valid placekeys return True"""
        assert placekey_isvalid("abc-234-xyz") is True
        assert placekey_isvalid("@abc-234-xyz") is True
        assert placekey_isvalid("bcd-2u4-xez") is True
        assert placekey_isvalid("zzz@abc-234-xyz") is True
        assert placekey_isvalid("222-zzz@abc-234-xyz") is True

    def test_invalid_placekeys(self):
        """Test invalid placekeys return False"""
        assert placekey_isvalid(None) is False
        assert placekey_isvalid("@abc") is False
        assert placekey_isvalid("abc-xyz") is False
        assert placekey_isvalid("abcxyz234") is False
        assert placekey_isvalid("abc@abc-234-xyz") is False
        assert placekey_isvalid("ebc-345@abc-234-xyz") is False
        assert placekey_isvalid("bcd-345@") is False
        assert placekey_isvalid("22-zzz@abc-234-xyz") is False


class TestLambdaHandler:
    """Test the Lambda handler function"""

    def test_valid_placekey(self):
        """Test handler with valid placekey"""
        import json

        event = {"arguments": [["abc-234-xyz"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is True

    def test_invalid_placekey(self):
        """Test handler with invalid placekey"""
        import json

        event = {"arguments": [["@abc"]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is False

    def test_null_input(self):
        """Test handler with null input"""
        import json

        event = {"arguments": [[None]]}
        result_str = lambda_handler(event, None)
        result = json.loads(result_str)
        assert result["success"] is True
        assert result["results"][0] is False

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        import json

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
