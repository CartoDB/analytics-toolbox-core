"""
Path utilities for the Analytics Toolbox Gateway
"""

from pathlib import Path
from typing import Optional


def get_gateway_root() -> Path:
    """
    Get the root directory of the gateway

    Returns:
        Path to gateway root directory
    """
    # This file is at gateway/logic/common/utils/paths.py
    # Gateway root is 4 levels up
    return Path(__file__).parent.parent.parent.parent.resolve()


def get_functions_root() -> Path:
    """
    Get the functions directory

    Returns:
        Path to functions directory
    """
    return get_gateway_root() / "functions"


def get_logic_root() -> Path:
    """
    Get the logic directory

    Returns:
        Path to logic directory
    """
    return get_gateway_root() / "logic"


def get_dist_root() -> Path:
    """
    Get the distribution directory

    Returns:
        Path to dist directory
    """
    return get_gateway_root() / "dist"


def get_schemas_dir() -> Path:
    """
    Get the schemas directory

    Returns:
        Path to schemas directory
    """
    return get_logic_root() / "common" / "schemas"


def get_function_schema() -> Path:
    """
    Get the function.schema.json path

    Returns:
        Path to function schema
    """
    return get_schemas_dir() / "function.schema.json"


def ensure_dir(path: Path) -> Path:
    """
    Ensure a directory exists, creating it if necessary

    Args:
        path: Directory path

    Returns:
        The path (for chaining)
    """
    path.mkdir(parents=True, exist_ok=True)
    return path


def get_relative_path(path: Path, base: Optional[Path] = None) -> Path:
    """
    Get relative path from base (defaults to gateway root)

    Args:
        path: Path to make relative
        base: Base path (defaults to gateway root)

    Returns:
        Relative path
    """
    if base is None:
        base = get_gateway_root()

    try:
        return path.relative_to(base)
    except ValueError:
        # Path is not relative to base
        return path
