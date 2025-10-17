"""Unit tests for QUADKEY_BBOX function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadkey_bbox_basic(self):
        """Test basic quadkey bbox calculation"""
        event = {"arguments": [["0"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        bbox = json.loads(result["results"][0])
        assert isinstance(bbox, list)
        assert len(bbox) == 4  # [west, south, east, north]
        # Check all are floats
        assert all(isinstance(x, (int, float)) for x in bbox)

    def test_quadkey_bbox_valid(self):
        """Test valid quadkey"""
        event = {"arguments": [["03"]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        bbox = json.loads(result["results"][0])
        assert isinstance(bbox, list)
        assert len(bbox) == 4
        # west < east, south < north
        assert bbox[0] < bbox[2]
        assert bbox[1] < bbox[3]

    def test_quadkey_bbox_multiple(self):
        """Test multiple quadkeys"""
        event = {"arguments": [["0"], ["1"], ["2"]], "num_records": 3}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 3
        for i in range(3):
            bbox = json.loads(result["results"][i])
            assert isinstance(bbox, list)
            assert len(bbox) == 4

    def test_quadkey_bbox_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadkey_bbox_empty(self):
        """Test empty input handling"""
        event = {"arguments": [[]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]
