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
        """Test kring distances with size 1 - verify exact expected values"""
        # Size 1 should return 9 cells with distances 0-1
        # Expected from original test:
        # [{'index': 2, 'distance': 1}, {'index': 34, 'distance': 1},
        #  {'index': 66, 'distance': 1}, {'index': 130, 'distance': 1},
        #  {'index': 162, 'distance': 0}, {'index': 194, 'distance': 1},
        #  {'index': 258, 'distance': 1}, {'index': 290, 'distance': 1},
        #  {'index': 322, 'distance': 1}]
        event = {"arguments": [[162, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 9

        # Convert to dict for easier verification
        kring_dict = {item["index"]: item["distance"] for item in kring}

        # Verify exact expected values
        expected = {
            2: 1,
            34: 1,
            66: 1,
            130: 1,
            162: 0,  # origin
            194: 1,
            258: 1,
            290: 1,
            322: 1,
        }
        assert kring_dict == expected

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
