"""Unit tests for QUADINT_KRING function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_kring_basic(self):
        """Test basic kring calculation"""
        # Size 0 should return only the origin
        event = {"arguments": [[162, 0]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 1
        assert kring[0] == 162

    def test_quadint_kring_size_1(self):
        """Test kring with size 1"""
        # Size 1 should return 9 cells (3x3 grid)
        event = {"arguments": [[162, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 9  # (2*1+1)^2

    def test_quadint_kring_size_2(self):
        """Test kring with size 2"""
        # Size 2 should return 25 cells (5x5 grid)
        event = {"arguments": [[162, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        kring = json.loads(result["results"][0])
        assert isinstance(kring, list)
        assert len(kring) == 25  # (2*2+1)^2

    def test_quadint_kring_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Invalid input" in result["error_msg"]

    def test_quadint_kring_invalid_size(self):
        """Test invalid size"""
        event = {"arguments": [[162, -1]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Invalid input" in result["error_msg"]
