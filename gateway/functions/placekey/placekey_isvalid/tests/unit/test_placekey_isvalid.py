"""
Unit tests for PLACEKEY_ISVALID function
"""

import sys
from pathlib import Path

# Get the code directory for this function
function_root = Path(__file__).parent.parent.parent
code_dir = function_root / "code" / "lambda" / "python"

# Save and clear all lib.* modules to avoid conflicts with other functions
_original_sys_path = sys.path.copy()
_saved_lib_modules = {
    k: v for k, v in sys.modules.items() if k == "lib" or k.startswith("lib.")
}
for key in list(_saved_lib_modules.keys()):
    sys.modules.pop(key, None)

sys.path.insert(0, str(code_dir))
try:
    from lib import placekey_isvalid  # noqa: E402

    # Also load handler for lambda tests
    spec = __import__("importlib.util").util.spec_from_file_location(
        "handler", code_dir / "handler.py"
    )
    handler_module = __import__("importlib.util").util.module_from_spec(spec)
    spec.loader.exec_module(handler_module)
    lambda_handler = handler_module.lambda_handler
finally:
    # Restore sys.path and clear our lib modules
    sys.path[:] = _original_sys_path
    for key in list(sys.modules.keys()):
        if key == "lib" or key.startswith("lib."):
            sys.modules.pop(key, None)
    sys.modules.update(_saved_lib_modules)


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
