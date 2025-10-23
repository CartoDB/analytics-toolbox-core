"""Unit tests for QUADINT_TOCHILDREN function"""

import json
from test_utils.unit import load_function_module

# Load the function module with lib imports
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]


class TestLambdaHandler:
    """Tests for the Lambda handler"""

    def test_quadint_tochildren_basic(self):
        """Test children calculation"""
        # Get children one level down
        event = {"arguments": [[162, 6]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        assert result["num_records"] == 1
        children = json.loads(result["results"][0])
        assert isinstance(children, list)
        assert len(children) > 0
        # All should be integers
        assert all(isinstance(c, int) for c in children)

    def test_quadint_tochildren_multiple_levels(self):
        """Test children at different resolution differences"""
        event = {"arguments": [[162, 7]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is True
        children = json.loads(result["results"][0])
        assert isinstance(children, list)
        assert len(children) > 0
        # Number of children should grow with resolution difference
        assert all(isinstance(c, int) for c in children)

    def test_quadint_tochildren_null(self):
        """Test NULL input handling"""
        event = {"arguments": [[None, 6]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "NULL argument passed to UDF" in result["error_msg"]

    def test_quadint_tochildren_invalid_resolution(self):
        """Test invalid resolution - must be greater than current zoom"""
        event = {"arguments": [[162, 2]], "num_records": 1}
        result_str = lambda_handler(event)
        result = json.loads(result_str)

        assert result["success"] is False
        assert "Wrong resolution" in result["error_msg"]
