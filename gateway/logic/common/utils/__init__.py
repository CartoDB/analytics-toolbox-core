"""
Utility functions for the Analytics Toolbox Gateway
"""

from .logging import setup_logger, get_logger
from .paths import (
    get_gateway_root,
    get_default_function_roots,
    get_logic_root,
    get_dist_root,
    get_schemas_dir,
    get_function_schema,
    ensure_dir,
    get_relative_path,
)

__all__ = [
    "setup_logger",
    "get_logger",
    "get_gateway_root",
    "get_default_function_roots",
    "get_logic_root",
    "get_dist_root",
    "get_schemas_dir",
    "get_function_schema",
    "ensure_dir",
    "get_relative_path",
]
