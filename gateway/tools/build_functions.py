#!/usr/bin/env python3
"""
Build script for Gateway functions

Creates a build/ directory with functions that have shared libraries copied
into their lib/ directories. This mirrors the deployment structure so tests
can run against the actual package layout.

Usage:
    python tools/build_functions.py [--cloud redshift] [--clean]
"""

import sys
import shutil
import argparse
from pathlib import Path

# Add parent directories to path for imports
gateway_root = Path(__file__).parent.parent
sys.path.insert(0, str(gateway_root))

from logic.common.engine import CatalogLoader, CloudType
from logic.common.utils import get_default_function_roots, setup_logger

logger = setup_logger("build")


def copy_shared_libs(func, func_dst: Path, gateway_root: Path):
    """
    Copy shared libraries into function's lib directory.

    Args:
        func: Function object with function.yaml configuration
        func_dst: Destination directory for the function in build/
        gateway_root: Gateway root directory
    """
    import yaml

    yaml_path = func.function_path / "function.yaml"
    if not yaml_path.exists():
        return

    with open(yaml_path, "r") as f:
        config = yaml.safe_load(f)

    # Check if function has shared_libs configuration for this cloud
    clouds_config = config.get("clouds", {})

    # Try to get cloud-specific shared_libs
    shared_libs = []
    for cloud_name, cloud_config in clouds_config.items():
        if isinstance(cloud_config, dict) and "shared_libs" in cloud_config:
            shared_libs = cloud_config.get("shared_libs", [])
            break  # Use first cloud's shared_libs (usually consistent across clouds)

    if not shared_libs:
        return  # No shared libraries to copy

    shared_root = gateway_root / "functions" / "_shared" / "python"
    if not shared_root.exists():
        logger.warning(f"Shared libraries directory not found: {shared_root}")
        return

    logger.debug(f"  Copying shared libs for {func.name}: {shared_libs}")

    for lib_name in shared_libs:
        # Handle both directory and file references
        lib_src = shared_root / lib_name

        if lib_src.is_dir():
            # Copy entire directory (e.g., "clustering" -> lib/clustering/)
            lib_dst = func_dst / "code" / "lambda" / "python" / "lib" / lib_name
            if lib_dst.exists():
                shutil.rmtree(lib_dst)
            shutil.copytree(
                lib_src,
                lib_dst,
                ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "tests"),
            )
            logger.debug(f"    ✓ {lib_name}/ -> lib/{lib_name}/")

        elif lib_src.is_file() or (lib_src.parent / f"{lib_name}.py").is_file():
            # Copy single file (e.g., "quadkey/helper.py" -> lib/helper.py)
            if not lib_src.is_file():
                lib_src = lib_src.parent / f"{lib_name}.py"

            lib_dst = func_dst / "code" / "lambda" / "python" / "lib" / lib_src.name
            lib_dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(lib_src, lib_dst)
            logger.debug(f"    ✓ {lib_name} -> lib/{lib_src.name}")
        else:
            logger.warning(f"    ✗ Shared library not found: {lib_name} in {shared_root}")


def build_functions(cloud: CloudType, clean: bool = False):
    """
    Build functions directory with shared libraries copied.

    Args:
        cloud: Cloud platform to build for
        clean: If True, remove build directory first
    """
    gateway_root = get_default_function_roots().parent
    build_dir = gateway_root / "build"
    functions_build = build_dir / "functions"

    # Clean build directory if requested
    if clean and build_dir.exists():
        logger.info(f"Cleaning build directory: {build_dir}")
        shutil.rmtree(build_dir)

    # Load catalog
    logger.info(f"Loading functions for {cloud.value}...")
    loader = CatalogLoader(get_default_function_roots())
    loader.load_catalog()

    functions = loader.get_functions_by_cloud(cloud)
    logger.info(f"Found {len(functions)} functions for {cloud.value}")

    # Create build directory
    build_dir.mkdir(exist_ok=True)
    functions_build.mkdir(exist_ok=True)

    # Track stats
    functions_with_shared_libs = 0
    total_libs_copied = 0

    # Copy each function
    for func in functions:
        # Reconstruct path as: build/functions/<module>/<function_name>
        func_dst = functions_build / func.module / func.name

        # Skip if already built (unless clean was requested)
        if func_dst.exists() and not clean:
            continue

        # Copy function directory
        if func_dst.exists():
            shutil.rmtree(func_dst)

        func_dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(
            func.function_path,
            func_dst,
            ignore=shutil.ignore_patterns(
                "__pycache__",
                "*.pyc",
                "*.pyo",
                ".pytest_cache",
                # Don't exclude tests - we want them in build for testing
            ),
        )

        # Check if function has shared libraries
        import yaml
        yaml_path = func.function_path / "function.yaml"
        if yaml_path.exists():
            with open(yaml_path, "r") as f:
                config = yaml.safe_load(f)

            # Check for shared_libs in any cloud config
            has_shared_libs = False
            for cloud_config in config.get("clouds", {}).values():
                if isinstance(cloud_config, dict) and cloud_config.get("shared_libs"):
                    has_shared_libs = True
                    functions_with_shared_libs += 1
                    break

            if has_shared_libs:
                # Copy shared libraries
                before_count = total_libs_copied
                copy_shared_libs(func, func_dst, gateway_root)
                # Count libs copied by checking lib directory
                lib_dir = func_dst / "code" / "lambda" / "python" / "lib"
                if lib_dir.exists():
                    lib_count = len([d for d in lib_dir.iterdir() if d.is_dir() or d.suffix == '.py'])
                    total_libs_copied += lib_count

    logger.info(f"\n{'='*60}")
    logger.info(f"Build Summary:")
    logger.info(f"{'='*60}")
    logger.info(f"  Total functions: {len(functions)}")
    logger.info(f"  Functions with shared libs: {functions_with_shared_libs}")
    logger.info(f"  Build directory: {build_dir}")
    logger.info(f"{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(
        description="Build gateway functions with shared libraries"
    )
    parser.add_argument(
        "--cloud",
        default="redshift",
        help="Cloud platform to build for (default: redshift)"
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Clean build directory before building"
    )

    args = parser.parse_args()

    try:
        cloud = CloudType(args.cloud.lower())
    except ValueError:
        logger.error(f"Invalid cloud type: {args.cloud}")
        logger.error("Valid options: redshift, bigquery, snowflake, databricks")
        sys.exit(1)

    build_functions(cloud, clean=args.clean)
    logger.info("✓ Build complete")


if __name__ == "__main__":
    main()
