#!/usr/bin/env python3
"""
Install function dependencies for testing.

This script scans function directories and installs their requirements
into the current virtual environment. This allows unit tests to import
function code without pre-installing all dependencies.

Usage:
    python tools/install_function_deps.py [--cloud CLOUD] [--modules MODULES] [--functions FUNCTIONS]

Arguments:
    --cloud: Optional cloud filter (redshift, bigquery, snowflake, databricks, postgres)
    --modules: Optional comma-separated list of modules to install deps for
    --functions: Optional comma-separated list of functions to install deps for
"""

import argparse
import subprocess
import sys
from pathlib import Path
from collections import defaultdict
import yaml


def get_function_cloud_support(function_yaml_path):
    """Parse function.yaml to determine which clouds this function supports."""
    try:
        with open(function_yaml_path) as f:
            config = yaml.safe_load(f)
            if config and "clouds" in config:
                return set(config["clouds"].keys())
    except Exception as e:
        print(f"Warning: Could not parse {function_yaml_path}: {e}", file=sys.stderr)
    return set()


def collect_requirements_files(function_roots, cloud_filter=None, modules=None, functions=None):
    """
    Scan functions and collect their requirements files.

    Args:
        function_roots: List of root directories to scan for functions

    Returns:
        list: Paths to requirements.txt files
    """
    requirements_files = []

    # Convert filter arguments to sets
    module_filter = set(modules.split(',')) if modules else None
    function_filter = set(functions.split(',')) if functions else None

    for functions_dir in function_roots:
        functions_path = Path(functions_dir)
        if not functions_path.exists():
            continue

        for req_file in sorted(functions_path.rglob("requirements.txt")):
            # Skip test requirements
            if "tests" in str(req_file):
                continue

            # Get module and function name
            # Typical path: functions/module/function_name/code/lambda/python/requirements.txt
            parts = req_file.parts
            if "functions" not in parts:
                continue

            func_idx = parts.index("functions")
            if func_idx + 2 >= len(parts):
                continue

            module_name = parts[func_idx + 1]
            function_name = parts[func_idx + 2]

            # Apply module filter
            if module_filter and module_name not in module_filter:
                continue

            # Apply function filter
            if function_filter and function_name not in function_filter:
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

            requirements_files.append((req_file, module_name, function_name))

    return requirements_files


def _deduplicate_and_check(requirements):
    """
    Deduplicate requirements and fail if conflicts are detected.

    Raises:
        SystemExit: If version conflicts are detected
    """
    from packaging.requirements import Requirement

    # Group by package name
    packages = {}
    for req_str in requirements:
        req_str = req_str.strip()
        if not req_str or req_str.startswith('#'):
            continue

        try:
            req = Requirement(req_str)
            pkg_name = req.name.lower()

            if pkg_name not in packages:
                packages[pkg_name] = []
            packages[pkg_name].append(req_str)

        except Exception as e:
            print(f"Warning: Could not parse requirement '{req_str}': {e}", file=sys.stderr)
            # Keep unparseable requirements as-is
            if 'unparseable' not in packages:
                packages['unparseable'] = []
            packages['unparseable'].append(req_str)

    # Build deduplicated set and check for conflicts
    result = set()
    conflicts = []

    for pkg_name, req_strings in packages.items():
        if pkg_name == 'unparseable':
            result.update(req_strings)
            continue

        unique_reqs = sorted(set(req_strings))
        if len(unique_reqs) == 1:
            result.add(unique_reqs[0])
        else:
            # Conflict detected!
            conflicts.append((pkg_name, unique_reqs))

    # Fail on conflicts
    if conflicts:
        print("\n❌ Version conflicts detected in function requirements:\n", file=sys.stderr)
        for pkg_name, versions in conflicts:
            print(f"  Package: {pkg_name}", file=sys.stderr)
            for ver in versions:
                print(f"    {ver}", file=sys.stderr)
            print("", file=sys.stderr)

        print("❌ Please update the function requirements files to use consistent versions.", file=sys.stderr)
        print("All functions should use the same version for each package.", file=sys.stderr)
        print("\nNote: Each Lambda function deploys with its own isolated requirements,", file=sys.stderr)
        print("but for local testing, only ONE version can be installed per package.\n", file=sys.stderr)
        sys.exit(1)

    return result


def install_requirements(requirements_files):
    """Install requirements from collected files."""
    if not requirements_files:
        print("No function requirements to install")
        return True

    print(f"Installing dependencies for {len(requirements_files)} function(s)...")

    # Collect all requirements into a temp file to install in one go
    temp_req_file = Path("/tmp/at_gateway_function_deps.txt")

    all_requirements = set()
    function_names = []

    for req_file, module_name, function_name in requirements_files:
        function_names.append(f"{module_name}/{function_name}")
        with open(req_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    all_requirements.add(line)

    if not all_requirements:
        print("No requirements found in function files")
        return True

    print(f"Functions: {', '.join(function_names)}")

    # Deduplicate and check for conflicts (fails if found)
    deduplicated = _deduplicate_and_check(all_requirements)
    print(f"Installing {len(deduplicated)} unique package(s)...")

    # Write temp requirements file
    with open(temp_req_file, 'w') as f:
        for req in sorted(deduplicated):
            f.write(f"{req}\n")

    # Install using pip
    try:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "-r", str(temp_req_file)],
            check=True,
            capture_output=False  # Show pip output for debugging
        )
        print("✓ Function dependencies installed successfully")
        temp_req_file.unlink(missing_ok=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Error installing dependencies: {e}", file=sys.stderr)
        print(f"Requirements file saved at: {temp_req_file}", file=sys.stderr)
        print(f"Run this to see the error: pip install -r {temp_req_file}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Install function dependencies for testing"
    )
    parser.add_argument(
        "--cloud",
        choices=["redshift", "bigquery", "snowflake", "databricks", "postgres"],
        help="Filter by cloud platform (optional)",
    )
    parser.add_argument(
        "--modules",
        help="Comma-separated list of modules to install deps for (optional)",
    )
    parser.add_argument(
        "--functions",
        help="Comma-separated list of functions to install deps for (optional)",
    )
    parser.add_argument(
        "--include-root",
        action="append",
        dest="include_roots",
        help="Additional function root directories to scan (can be specified multiple times)",
    )
    args = parser.parse_args()

    # Determine gateway root
    script_path = Path(__file__).resolve()
    gateway_root = script_path.parent.parent

    # Build list of function roots to scan
    function_roots = [gateway_root / "functions"]
    if args.include_roots:
        function_roots.extend(args.include_roots)

    print(f"Scanning function directories:")
    for root in function_roots:
        print(f"  - {root}")
    if args.cloud:
        print(f"Filtering by cloud: {args.cloud}")
    if args.modules:
        print(f"Filtering by modules: {args.modules}")
    if args.functions:
        print(f"Filtering by functions: {args.functions}")

    # Collect requirements files
    requirements_files = collect_requirements_files(
        function_roots,
        args.cloud,
        args.modules,
        args.functions
    )

    # Install requirements
    success = install_requirements(requirements_files)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
