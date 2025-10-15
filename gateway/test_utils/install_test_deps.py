#!/usr/bin/env python3
"""
Dynamically discover and install function requirements for testing.

This script is useful for CI/CD environments where you want to install only
the dependencies needed for a specific cloud platform's tests.

Usage:
    python test_utils/install_test_deps.py [--cloud CLOUD] [--target DIR]

Arguments:
    --cloud: Cloud platform to install dependencies for (redshift, bigquery, etc.)
             Default: redshift
    --target: Target directory for installation (optional)
              If not specified, installs to current environment
    --dry-run: Print what would be installed without actually installing

Examples:
    # Install all Redshift function dependencies
    python test_utils/install_test_deps.py --cloud redshift

    # Install to a specific directory
    python test_utils/install_test_deps.py --cloud redshift --target ./lib

    # See what would be installed
    python test_utils/install_test_deps.py --cloud redshift --dry-run
"""

import argparse
import subprocess
import sys
from pathlib import Path
import yaml


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


def discover_function_requirements(gateway_root, cloud):
    """
    Find all function requirements.txt files for a given cloud.

    Args:
        gateway_root: Path to gateway root directory
        cloud: Cloud name (e.g., 'redshift')

    Returns:
        list: List of Path objects pointing to requirements.txt files
    """
    requirements_files = []
    functions_dir = Path(gateway_root) / "functions"

    for req_file in sorted(functions_dir.rglob("requirements.txt")):
        # Skip test requirements
        if "tests" in str(req_file):
            continue

        # Get function directory and check if it has function.yaml
        # Typical path: functions/module/function_name/code/lambda/python/requirements.txt
        function_dir = req_file.parent.parent.parent.parent
        function_yaml = function_dir / "function.yaml"

        if not function_yaml.exists():
            continue

        # Check if this function supports the target cloud
        supported_clouds = get_function_cloud_support(function_yaml)

        if cloud in supported_clouds:
            requirements_files.append(req_file)

    return requirements_files


def install_requirements(requirements_files, target_dir=None, dry_run=False):
    """
    Install all discovered requirements.

    Args:
        requirements_files: List of Path objects pointing to requirements.txt
        target_dir: Optional target directory for installation
        dry_run: If True, only print what would be installed
    """
    if not requirements_files:
        print("No function requirements found for the specified cloud")
        return 0

    print(f"Found {len(requirements_files)} function requirement files:")
    for req_file in requirements_files:
        print(f"  - {req_file}")

    if dry_run:
        print("\nDry run - would install the above requirements")
        return 0

    print("\nInstalling dependencies...")
    failed = []

    for req_file in requirements_files:
        print(f"\n→ Installing from: {req_file.relative_to(req_file.parents[6])}")

        cmd = [sys.executable, "-m", "pip", "install", "-r", str(req_file)]

        if target_dir:
            cmd.extend(["-t", target_dir])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=False)

            if result.returncode != 0:
                print(f"  ✗ Failed to install")
                print(f"    Error: {result.stderr}")
                failed.append(req_file)
            else:
                print(f"  ✓ Installed successfully")

        except Exception as e:
            print(f"  ✗ Exception during installation: {e}")
            failed.append(req_file)

    print("\n" + "=" * 60)
    if failed:
        print(f"✗ Installation completed with {len(failed)} failures:")
        for req_file in failed:
            print(f"  - {req_file}")
        return 1
    else:
        print(
            f"✓ Successfully installed all {len(requirements_files)} requirement files"
        )
        return 0


def main():
    parser = argparse.ArgumentParser(
        description="Install function requirements for testing",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--cloud",
        default="redshift",
        choices=["redshift", "bigquery", "snowflake", "databricks", "postgres"],
        help="Cloud platform to install dependencies for (default: redshift)",
    )
    parser.add_argument("--target", help="Target directory for installation (optional)")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be installed without actually installing",
    )

    args = parser.parse_args()

    # Determine gateway root
    script_path = Path(__file__).resolve()
    gateway_root = script_path.parent.parent

    print(f"Gateway root: {gateway_root}")
    print(f"Cloud platform: {args.cloud}")
    if args.target:
        print(f"Target directory: {args.target}")
    print()

    # Discover requirements
    req_files = discover_function_requirements(gateway_root, args.cloud)

    # Install
    exit_code = install_requirements(req_files, args.target, args.dry_run)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
