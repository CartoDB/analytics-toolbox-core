#!/usr/bin/env python3
"""
Generate requirements-dev.txt from all function requirements.

This script scans all function directories and consolidates their requirements
into a single requirements-dev.txt file for local development and testing.

Usage:
    python tools/generate_dev_requirements.py [--cloud CLOUD]

Arguments:
    --cloud: Optional cloud filter (redshift, bigquery, snowflake, databricks, postgres)
             If not specified, includes all clouds.
"""

import argparse
import sys
from pathlib import Path
from collections import defaultdict
import yaml


def parse_requirement_line(line):
    """
    Parse a requirement line into (package, version_spec, raw_line)

    Examples:
        "geojson==3.1.0" -> ("geojson", "==3.1.0", "geojson==3.1.0")
        "scipy>=1.11.4" -> ("scipy", ">=1.11.4", "scipy>=1.11.4")
        "numpy" -> ("numpy", None, "numpy")
    """
    line = line.strip()

    # Handle comments
    if "#" in line:
        line = line.split("#")[0].strip()

    if not line:
        return None, None, None

    # Parse version specifiers
    for op in ["==", ">=", "<=", "~=", "!=", ">", "<"]:
        if op in line:
            package, version = line.split(op, 1)
            return package.strip(), f"{op}{version.strip()}", line

    # No version specified
    return line.strip(), None, line


def get_function_cloud_support(function_yaml_path):
    """
    Parse function.yaml to determine which clouds this function supports.

    Returns:
        set: Set of cloud names (e.g., {'redshift', 'bigquery'})
    """
    try:
        with open(function_yaml_path) as f:
            config = yaml.safe_load(f)
            if config and "clouds" in config:
                return set(config["clouds"].keys())
    except Exception as e:
        print(f"Warning: Could not parse {function_yaml_path}: {e}", file=sys.stderr)

    return set()


def discover_function_requirements(gateway_root, cloud_filter=None):
    """
    Scan all functions and collect their requirements.

    Args:
        gateway_root: Path to gateway root directory
        cloud_filter: Optional cloud name to filter by (e.g., 'redshift')

    Returns:
        dict: {
            package_name: {
                'versions': set of version specs,
                'functions': list of (function_name, cloud) tuples,
                'raw_line': example raw requirement line
            }
        }
    """
    requirements = defaultdict(
        lambda: {"versions": set(), "functions": [], "raw_line": None}
    )

    functions_dir = Path(gateway_root) / "functions"

    for req_file in sorted(functions_dir.rglob("requirements.txt")):
        # Skip test requirements
        if "tests" in str(req_file):
            continue

        # Get function name
        # Typical path: functions/module/function_name/code/lambda/python/requirements.txt
        parts = req_file.parts
        if "functions" in parts:
            func_idx = parts.index("functions")
            if func_idx + 2 < len(parts):
                function_name = parts[func_idx + 2]
            else:
                continue
        else:
            continue

        # Check cloud support
        function_dir = req_file.parent.parent.parent.parent
        function_yaml = function_dir / "function.yaml"

        if not function_yaml.exists():
            continue

        supported_clouds = get_function_cloud_support(function_yaml)

        # Apply cloud filter
        if cloud_filter and cloud_filter not in supported_clouds:
            continue

        clouds_str = ",".join(sorted(supported_clouds))

        # Parse requirements file
        with open(req_file) as f:
            for line in f:
                package, version_spec, raw_line = parse_requirement_line(line)

                if not package:
                    continue

                requirements[package]["versions"].add(version_spec)
                requirements[package]["functions"].append((function_name, clouds_str))

                if not requirements[package]["raw_line"]:
                    requirements[package]["raw_line"] = raw_line

    return requirements


def generate_dev_requirements_content(gateway_root, cloud_filter=None):
    """
    Generate the content for requirements-dev.txt.

    Args:
        gateway_root: Path to gateway root directory
        cloud_filter: Optional cloud name to filter by

    Returns:
        str: Content for requirements-dev.txt
    """
    requirements = discover_function_requirements(gateway_root, cloud_filter)

    # Build output
    lines = []
    lines.append("# Development dependencies")
    lines.append("# Auto-generated from function requirements - DO NOT EDIT MANUALLY")
    lines.append("# Run: python tools/generate_dev_requirements.py")
    if cloud_filter:
        lines.append(f"# Cloud filter: {cloud_filter}")
    lines.append("")
    lines.append("-r requirements.txt")
    lines.append("")
    lines.append("# Testing")
    lines.append("pytest>=8.0.0")
    lines.append("pytest-cov>=4.0.0")
    lines.append("pytest-mock>=3.10.0")
    lines.append("")
    lines.append("# Integration testing (Redshift connection)")
    lines.append("redshift-connector>=2.0.0")
    lines.append("")
    lines.append("# Code quality - Python")
    lines.append(
        "# Note: Using black directly (brunette fork used in clouds has Python 3.13 issues)"
    )
    lines.append("black>=23.0.0")
    lines.append("flake8>=6.0.0")
    lines.append("flake8-quotes>=3.3.0")
    lines.append("mypy>=1.0.0")
    lines.append("")
    lines.append("# Type stubs")
    lines.append("types-PyYAML>=6.0")
    lines.append("types-requests>=2.28")
    lines.append("boto3-stubs[lambda,iam,s3]>=1.26.0")
    lines.append("")
    lines.append("# Function dependencies needed for unit testing")
    lines.append(
        "# These allow tests to import function code without installing each function's requirements"
    )

    # Sort packages alphabetically
    for package in sorted(requirements.keys()):
        info = requirements[package]
        versions = info["versions"]
        functions = info["functions"]

        # Group functions by cloud
        func_cloud_map = defaultdict(list)
        for func_name, clouds in functions:
            func_cloud_map[clouds].append(func_name)

        # Build function list string
        func_parts = []
        for clouds, funcs in sorted(func_cloud_map.items()):
            funcs_str = ", ".join(sorted(set(funcs)))
            func_parts.append(f"{funcs_str} ({clouds})")
        func_list = "; ".join(func_parts)

        # Check for version conflicts
        # Remove None from versions
        actual_versions = {v for v in versions if v is not None}

        if len(actual_versions) > 1:
            lines.append(
                f"# WARNING: Version conflict for {package}: {actual_versions}"
            )
            lines.append(f"# {package}  # Used by: {func_list}")
            lines.append(f"{package}  # CONFLICT - manual resolution needed")
        elif len(actual_versions) == 1:
            version_spec = list(actual_versions)[0]
            lines.append(f"{package}{version_spec}  # Used by: {func_list}")
        else:
            # No version specified
            lines.append(f"{package}  # Used by: {func_list}")

    lines.append("")  # Trailing newline
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Generate requirements-dev.txt from function requirements"
    )
    parser.add_argument(
        "--cloud",
        choices=["redshift", "bigquery", "snowflake", "databricks", "postgres"],
        help="Filter by cloud platform (optional)",
    )
    args = parser.parse_args()

    # Determine gateway root
    script_path = Path(__file__).resolve()
    gateway_root = script_path.parent.parent

    print(f"Scanning functions in: {gateway_root / 'functions'}")
    if args.cloud:
        print(f"Filtering by cloud: {args.cloud}")

    # Generate content
    content = generate_dev_requirements_content(gateway_root, args.cloud)

    # Write to file
    output_file = gateway_root / "requirements-dev.txt"
    with open(output_file, "w") as f:
        f.write(content)

    print(f"\n✓ Generated {output_file}")
    print(f"  Run: pip install -r requirements-dev.txt")


if __name__ == "__main__":
    main()
