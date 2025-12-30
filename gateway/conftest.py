"""
Pytest configuration for Analytics Toolbox Gateway

This file automatically configures the test environment to make platform
runtime utilities available under the same namespace used in deployment.

Supports multiple platforms (AWS Lambda, GCP Cloud Functions, etc.) by
auto-discovering runtime directories and creating appropriate module aliases.
"""

import sys
from pathlib import Path


def setup_platform_runtime(platform_name: str, runtime_module: str, namespace: str):
    """
    Setup a platform runtime for testing.

    Args:
        platform_name: Platform directory name (e.g., 'aws-lambda', 'gcp-cloud-functions')
        runtime_module: Module name to import (e.g., 'lambda_wrapper', 'cloud_run_wrapper')
        namespace: Deployment namespace (e.g., 'carto')
    """
    gateway_root = Path(__file__).parent
    runtime_path = gateway_root / "logic" / "platforms" / platform_name / "runtime"

    if not runtime_path.exists():
        return  # Platform not available

    # Add runtime to path
    if str(runtime_path) not in sys.path:
        sys.path.insert(0, str(runtime_path))

    # Create module alias to match deployment packaging
    try:
        module = __import__(runtime_module)
        sys.modules[f"{namespace}.{runtime_module}"] = module

        # Also create parent namespace if needed
        if namespace not in sys.modules:
            sys.modules[namespace] = module
    except ImportError:
        pass  # Module not available


# Setup AWS Lambda runtime (Redshift, Snowflake)
setup_platform_runtime(
    platform_name="aws-lambda",
    runtime_module="lambda_wrapper",
    namespace="carto",
)

# Setup future platforms as they're added:
# setup_platform_runtime(
#     platform_name='gcp-cloud-functions',
#     runtime_module='cloud_run_wrapper',
#     namespace='carto'
# )


# ============================================================================
# Shared Test Utilities
# ============================================================================
#
# NOTE: Test utilities have been moved to test_utils/ for better organization:
#
# Unit tests (language-specific):
#   - test_utils/unit/python.py: Python Lambda/Cloud Run helpers
#   - test_utils/unit/javascript.py: JavaScript/Node.js helpers (future)
#   - test_utils/unit/go.py: Go helpers (future)
#
# Integration tests (cloud-specific):
#   - test_utils/integration/redshift.py: Amazon Redshift helpers
#   - test_utils/integration/bigquery.py: Google BigQuery helpers (future)
#   - test_utils/integration/snowflake.py: Snowflake helpers (future)
#   - test_utils/integration/databricks.py: Databricks helpers (future)
#
# This conftest.py re-exports utilities for backward compatibility.
# New tests should import directly from test_utils.
# ============================================================================

from test_utils.unit import load_function_module  # noqa: F401
from test_utils.integration.redshift import run_query, redshift_query  # noqa: F401
