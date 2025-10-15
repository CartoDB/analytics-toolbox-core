"""
Unit tests for PLACEKEY_FROMH3 function
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
    from lib import placekey_fromh3  # noqa: E402
    from lib.placekey import h3_is_valid  # noqa: E402

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
