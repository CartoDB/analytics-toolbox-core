"""
Lambda wrapper utilities for external functions
Provides standardized error handling and response formatting
"""

from typing import Dict, Any, Callable, List, Optional
import traceback


class ExternalFunctionResponse:
    """Builder for external function responses (cloud-agnostic)"""

    @staticmethod
    def success(results: List[Any], num_records: int) -> Dict[str, Any]:
        """
        Create a successful response

        Args:
            results: List of results (one per input row)
            num_records: Number of records processed

        Returns:
            Response dict in external function format
        """
        return {"success": True, "num_records": num_records, "results": results}

    @staticmethod
    def error(error_msg: str, num_records: int = 0) -> Dict[str, Any]:
        """
        Create an error response

        Args:
            error_msg: Error message to return
            num_records: Number of records (usually 0 for errors)

        Returns:
            Response dict in external function format
        """
        return {
            "success": False,
            "error_msg": error_msg,
            "num_records": num_records,
            "results": [],
        }


def redshift_handler(process_row_func: Callable) -> Callable:
    """
    Decorator to wrap a row processing function for Redshift Lambda

    The wrapped function should take a single row (list of arguments)
    and return a result or None.

    Args:
        process_row_func: Function that processes a single row

    Returns:
        Lambda handler function

    Example:
        @redshift_handler
        def process_row(row):
            if not row or len(row) < 2:
                return None
            arg1, arg2 = row[0], row[1]
            return arg1 + arg2

        # Can now use process_row as lambda_handler
    """

    def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
        try:
            arguments = event.get("arguments", [])
            num_records = event.get("num_records", len(arguments))

            results = []

            for row in arguments:
                try:
                    result = process_row_func(row)
                    results.append(result)
                except Exception as row_error:
                    # Log individual row errors but continue processing
                    print(f"Error processing row: {row_error}")
                    if context and hasattr(context, "get_remaining_time_in_millis"):
                        time_ms = context.get_remaining_time_in_millis()
                        print(f"Remaining time: {time_ms}ms")
                    results.append(None)

            return ExternalFunctionResponse.success(results, num_records)

        except Exception as e:
            # Batch-level error
            error_msg = f"Batch processing error: {str(e)}"
            print(error_msg)
            print(traceback.format_exc())
            return ExternalFunctionResponse.error(error_msg)

    return lambda_handler


def batch_redshift_handler(process_batch_func: Callable) -> Callable:
    """
    Decorator to wrap a batch processing function for Redshift Lambda

    The wrapped function should take the full list of rows
    and return a list of results.

    Args:
        process_batch_func: Function that processes a batch of rows

    Returns:
        Lambda handler function

    Example:
        @batch_redshift_handler
        def process_batch(rows):
            # Process all rows at once (more efficient for some operations)
            return [process_single(row) for row in rows]
    """

    def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
        try:
            arguments = event.get("arguments", [])
            num_records = event.get("num_records", len(arguments))

            results = process_batch_func(arguments)

            # Ensure we have the right number of results
            if len(results) != len(arguments):
                error_msg = (
                    f"Result count mismatch: got {len(results)}, "
                    f"expected {len(arguments)}"
                )
                return ExternalFunctionResponse.error(error_msg)

            return ExternalFunctionResponse.success(results, num_records)

        except Exception as e:
            # Batch-level error
            error_msg = f"Batch processing error: {str(e)}"
            print(error_msg)
            print(traceback.format_exc())
            return ExternalFunctionResponse.error(error_msg)

    return lambda_handler


class LambdaContext:
    """Utilities for working with Lambda context"""

    @staticmethod
    def get_remaining_time_ms(context: Any) -> Optional[int]:
        """Get remaining execution time in milliseconds"""
        if context and hasattr(context, "get_remaining_time_in_millis"):
            return context.get_remaining_time_in_millis()
        return None

    @staticmethod
    def should_stop_processing(context: Any, buffer_ms: int = 5000) -> bool:
        """
        Check if Lambda should stop processing to avoid timeout

        Args:
            context: Lambda context
            buffer_ms: Buffer time in milliseconds

        Returns:
            True if should stop processing
        """
        remaining = LambdaContext.get_remaining_time_ms(context)
        if remaining is None:
            return False
        return remaining < buffer_ms
