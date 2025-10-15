"""
Unit tests for QUADBIN_POLYFILL function
Complex test scenarios that require Python test code
"""

import json
import pytest
import importlib.util
from pathlib import Path

# Load handler directly (this function has no lib directory)
handler_path = (
    Path(__file__).parent.parent.parent / "code" / "lambda" / "python" / "handler.py"
)
spec = importlib.util.spec_from_file_location("handler", handler_path)
handler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(handler)

quadbin_from_zxy = handler.quadbin_from_zxy
polyfill_geometry = handler.polyfill_geometry
lambda_handler = handler.lambda_handler


class TestQuadbinFromZXY:
    """Test the quadbin_from_zxy helper function"""

    def test_resolution_0(self):
        """Test resolution 0 returns just the zoom level"""
        result = quadbin_from_zxy(0, 0, 0)
        assert result == 0

    def test_invalid_zoom_negative(self):
        """Test negative zoom returns None"""
        result = quadbin_from_zxy(-1, 0, 0)
        assert result is None

    def test_invalid_zoom_too_high(self):
        """Test zoom > 26 returns None"""
        result = quadbin_from_zxy(27, 0, 0)
        assert result is None

    def test_invalid_x_coordinate(self):
        """Test invalid x coordinate returns None"""
        result = quadbin_from_zxy(4, 16, 0)  # x should be < 2^4 = 16
        assert result is None

    def test_invalid_y_coordinate(self):
        """Test invalid y coordinate returns None"""
        result = quadbin_from_zxy(4, 0, 16)  # y should be < 2^4 = 16
        assert result is None

    @pytest.mark.parametrize("z", range(0, 27))
    def test_all_valid_resolutions(self, z):
        """Test all valid resolutions produce results"""
        result = quadbin_from_zxy(z, 0, 0)
        assert result is not None
        assert isinstance(result, int)


class TestPolyfillGeometry:
    """Test the polyfill_geometry function"""

    def test_invalid_resolution_negative(self):
        """Test negative resolution returns empty list"""
        result = polyfill_geometry("POINT(0 0)", -1)
        assert result == []

    def test_invalid_resolution_too_high(self):
        """Test resolution > 26 returns empty list"""
        result = polyfill_geometry("POINT(0 0)", 27)
        assert result == []

    def test_resolution_0(self):
        """Test resolution 0 returns a single quadbin"""
        result = polyfill_geometry("POINT(0 0)", 0)
        assert len(result) == 1
        assert result[0] == 0

    def test_basic_point(self):
        """Test basic point returns at least one quadbin"""
        result = polyfill_geometry("POINT(-3.70325 40.4165)", 4)
        assert isinstance(result, list)
        assert len(result) > 0


class TestLambdaHandler:
    """Test the Lambda handler function"""

    def test_empty_event(self):
        """Test handler with empty event"""
        event = {"arguments": [], "num_records": 0}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 0
        assert result["results"] == []

    def test_single_valid_row(self):
        """Test handler with single valid row"""
        event = {"arguments": [["POINT(0 0)", 4]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        assert len(result["results"]) == 1
        assert result["results"][0] is not None

    def test_null_geometry(self):
        """Test handler with null geometry"""
        event = {"arguments": [[None, 4]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_null_resolution(self):
        """Test handler with null resolution"""
        event = {"arguments": [["POINT(0 0)", None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["results"][0] is None

    def test_batch_processing(self):
        """Test handler with multiple rows"""
        event = {
            "arguments": [
                ["POINT(0 0)", 4],
                ["POINT(1 1)", 5],
                [None, 4],
                ["POINT(2 2)", None],
            ],
            "num_records": 4,
        }
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 4
        assert len(result["results"]) == 4
        assert result["results"][0] is not None
        assert result["results"][1] is not None
        assert result["results"][2] is None
        assert result["results"][3] is None

    def test_malformed_row(self):
        """Test handler with malformed row"""
        event = {"arguments": [None, ["single_value"], []], "num_records": 3}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert all(r is None for r in result["results"])
