"""
Lambda wrapper utilities for external functions
Provides standardized error handling and response formatting
"""

from typing import Dict, Any, Callable, List, Optional
import traceback
import json
from enum import Enum


class ErrorHandlingMode(Enum):
    """Error handling modes for row-level errors"""

    SILENT = "silent"  # Log to CloudWatch, return None
    RETURN_ERROR = "return_error"  # Return error message as result
    FAIL_FAST = "fail_fast"  # Fail entire batch on first error


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


def redshift_handler(
    process_row_func: Callable = None,
    error_mode: ErrorHandlingMode = ErrorHandlingMode.FAIL_FAST,
) -> Callable:
    """
    Decorator to wrap a row processing function for Redshift Lambda

    The wrapped function should take a single row (list of arguments)
    and return a result or None.

    Args:
        process_row_func: Function that processes a single row
        error_mode: How to handle row-level errors (default: FAIL_FAST)

    Returns:
        Lambda handler function

    Example:
        @redshift_handler
        def process_row(row):
            if not row or len(row) < 2:
                return None
            arg1, arg2 = row[0], row[1]
            return arg1 + arg2

        # Or with explicit error mode:
        @redshift_handler(error_mode=ErrorHandlingMode.FAIL_FAST)
        def process_row(row):
            ...
    """

    def decorator(func: Callable) -> Callable:
        def lambda_handler(
            event: Dict[str, Any], context: Any = None
        ) -> Dict[str, Any]:
            try:
                arguments = event.get("arguments")
                num_records = event.get("num_records", 0)

                # Handle null arguments by creating empty rows based on num_records
                if arguments is None:
                    arguments = [[]] * num_records if num_records > 0 else []

                # Fallback to using length of arguments if num_records not provided
                if num_records == 0 and arguments:
                    num_records = len(arguments)

                results = []

                for i, row in enumerate(arguments):
                    try:
                        result = func(row)
                        results.append(result)
                    except Exception as row_error:
                        # Log to CloudWatch
                        error_msg = f"Error processing row {i}: {row_error}"
                        print(error_msg)
                        if context and hasattr(context, "get_remaining_time_in_millis"):
                            time_ms = context.get_remaining_time_in_millis()
                            print(f"Remaining time: {time_ms}ms")

                        # Handle based on error mode
                        if error_mode == ErrorHandlingMode.FAIL_FAST:
                            # Fail the entire batch
                            error_response = ExternalFunctionResponse.error(
                                error_msg, num_records
                            )
                            return json.dumps(error_response)
                        elif error_mode == ErrorHandlingMode.RETURN_ERROR:
                            # Return error as a JSON string so user sees it
                            error_result = json.dumps(
                                {
                                    "error": str(row_error),
                                    "row_index": i,
                                    "type": type(row_error).__name__,
                                }
                            )
                            results.append(error_result)
                        else:  # SILENT
                            # Return None (original behavior)
                            results.append(None)

                # Redshift expects JSON string response
                response = ExternalFunctionResponse.success(results, num_records)
                return json.dumps(response)

            except Exception as e:
                # Batch-level error
                error_msg = f"Batch processing error: {str(e)}"
                print(error_msg)
                print(traceback.format_exc())
                error_response = ExternalFunctionResponse.error(error_msg)
                return json.dumps(error_response)

        return lambda_handler

    # Support both @redshift_handler and @redshift_handler()
    if process_row_func is not None:
        return decorator(process_row_func)
    return decorator


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
            arguments = event.get("arguments")
            num_records = event.get("num_records", 0)

            # Handle null arguments by creating empty rows based on num_records
            if arguments is None:
                arguments = [[]] * num_records if num_records > 0 else []

            # Fallback to using length of arguments if num_records not provided
            if num_records == 0 and arguments:
                num_records = len(arguments)

            results = process_batch_func(arguments)

            # Ensure we have the right number of results
            if len(results) != len(arguments):
                error_msg = (
                    f"Result count mismatch: got {len(results)}, "
                    f"expected {len(arguments)}"
                )
                error_response = ExternalFunctionResponse.error(error_msg)
                return json.dumps(error_response)

            response = ExternalFunctionResponse.success(results, num_records)
            return json.dumps(response)

        except Exception as e:
            # Batch-level error
            error_msg = f"Batch processing error: {str(e)}"
            print(error_msg)
            print(traceback.format_exc())
            error_response = ExternalFunctionResponse.error(error_msg)
            return json.dumps(error_response)

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
