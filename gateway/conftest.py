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
        namespace: Deployment namespace (e.g., 'carto_analytics_toolbox_core')
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
    namespace="carto_analytics_toolbox_core",
)

# Setup future platforms as they're added:
# setup_platform_runtime(
#     platform_name='gcp-cloud-functions',
#     runtime_module='cloud_run_wrapper',
#     namespace='carto_analytics_toolbox_core'
# )
