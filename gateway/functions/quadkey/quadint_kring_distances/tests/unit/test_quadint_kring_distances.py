"""Unit tests for QUADINT_KRING_DISTANCES function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_kring_distances_basic(self):
        """Test basic kring with distances"""
        # Size 0 should return only origin with distance 0
        event = {"arguments": [[162, 0]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 1
        assert kring[0]["index"] == 162
        assert kring[0]["distance"] == 0

    def test_quadint_kring_distances_size_1(self):
        """Test kring distances with size 1"""
        # Size 1 should return 9 cells with distances 0-1
        event = {"arguments": [[162, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 9

        # Check all have index and distance fields
        for item in kring:
            assert "index" in item
            assert "distance" in item
            assert isinstance(item["index"], int)
            assert isinstance(item["distance"], int)
            assert 0 <= item["distance"] <= 1

        # Check origin has distance 0
        origin_items = [item for item in kring if item["index"] == 162]
        assert len(origin_items) == 1
        assert origin_items[0]["distance"] == 0

    def test_quadint_kring_distances_size_2(self):
        """Test kring distances with size 2"""
        # Size 2 should return 25 cells with distances 0-2
        event = {"arguments": [[162, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 25

        # All distances should be 0-2
        distances = [item["distance"] for item in kring]
        assert min(distances) == 0
        assert max(distances) == 2

    def test_quadint_kring_distances_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Invalid input" in result["error_msg"]

    def test_quadint_kring_distances_invalid_size(self):
        """Test invalid size"""
        event = {"arguments": [[162, -1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Invalid input" in result["error_msg"]
