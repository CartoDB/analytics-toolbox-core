"""
Unit tests for Lambda wrapper utilities
"""

from pathlib import Path
import sys

# Add runtime to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "runtime"))

from lambda_wrapper import (  # noqa: E402
    ExternalFunctionResponse,
    redshift_handler,
    batch_redshift_handler,
)


class TestExternalFunctionResponse:
    """Test ExternalFunctionResponse builder"""

    def test_success_response(self):
        """Test creating a success response"""
        results = [1, 2, 3]
        response = ExternalFunctionResponse.success(results, 3)

        assert response["success"] is True
        assert response["num_records"] == 3
        assert response["results"] == results

    def test_error_response(self):
        """Test creating an error response"""
        response = ExternalFunctionResponse.error("Test error", 0)

        assert response["success"] is False
        assert response["error_msg"] == "Test error"
        assert response["num_records"] == 0
        assert response["results"] == []


class TestRedshiftHandler:
    """Test redshift_handler decorator"""

    def test_successful_processing(self):
        """Test decorator with successful row processing"""

        @redshift_handler
        def process_row(row):
            if not row or len(row) < 2:
                return None
            return row[0] + row[1]

        event = {"arguments": [[1, 2], [3, 4], [5, 6]], "num_records": 3}

        response = process_row(event)

        assert response["success"] is True
        assert response["num_records"] == 3
        assert response["results"] == [3, 7, 11]

    def test_null_handling(self):
        """Test decorator with null values"""

        @redshift_handler
        def process_row(row):
            if not row or row[0] is None:
                return None
            return row[0] * 2

        event = {"arguments": [[5], [None], [10]], "num_records": 3}

        response = process_row(event)

        assert response["success"] is True
        assert response["results"] == [10, None, 20]

    def test_row_error_handling(self):
        """Test decorator handles row-level errors"""

        @redshift_handler
        def process_row(row):
            if not row:
                return None
            # This will raise an error for certain inputs
            return 10 / row[0]

        event = {
            "arguments": [[2], [0], [5]],  # Middle one will cause division by zero
            "num_records": 3,
        }

        response = process_row(event)

        assert response["success"] is True
        assert response["results"][0] == 5
        assert response["results"][1] is None  # Error case
        assert response["results"][2] == 2

    def test_batch_error_handling(self):
        """Test decorator handles row-level errors gracefully"""

        @redshift_handler
        def process_row(row):
            # Access invalid key to trigger error
            return row["invalid_key"]

        event = {"arguments": [[1, 2]], "num_records": 1}

        response = process_row(event)

        # Row-level errors are caught and return None for that row
        # The batch itself succeeds
        assert response["success"] is True
        assert response["results"] == [None]


class TestBatchRedshiftHandler:
    """Test batch_redshift_handler decorator"""

    def test_batch_processing(self):
        """Test decorator with batch processing"""

        @batch_redshift_handler
        def process_batch(rows):
            return [sum(row) for row in rows]

        event = {"arguments": [[1, 2], [3, 4, 5], [10]], "num_records": 3}

        response = process_batch(event)

        assert response["success"] is True
        assert response["num_records"] == 3
        assert response["results"] == [3, 12, 10]

    def test_result_count_mismatch(self):
        """Test error when result count doesn't match input count"""

        @batch_redshift_handler
        def process_batch(rows):
            # Return wrong number of results
            return [1, 2]  # Input has 3 rows

        event = {"arguments": [[1], [2], [3]], "num_records": 3}

        response = process_batch(event)

        assert response["success"] is False
        assert "mismatch" in response["error_msg"].lower()
