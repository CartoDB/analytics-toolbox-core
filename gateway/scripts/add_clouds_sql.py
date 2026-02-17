#!/usr/bin/env python3
"""
Add clouds SQL to gateway distribution package

This script filters and adds clouds SQL UDFs (modules.sql) to an existing
gateway package, creating a unified distribution with both Lambda functions
and native SQL UDFs.

Usage:
    python add_clouds_sql.py \
        --package-dir=dist/carto-at-redshift-1.0.0 \
        --cloud=redshift \
        [--source=clouds/redshift/modules/build/modules.sql] \
        [--modules=quadbin,tiler] \
        [--functions=QUADBIN_POLYFILL,QUADBIN_KRING] \
        [--append]

Arguments:
    --package-dir: Directory of the gateway package to enhance
    --cloud: Cloud name (redshift, bigquery, snowflake, databricks)
    --source: Path to source modules.sql (default: clouds/{cloud}/modules/build/modules.sql)
    --modules: Comma-separated list of modules to include
    --functions: Comma-separated list of specific functions to include
    --append: Append to existing modules.sql instead of overwriting
"""

import argparse
import re
from pathlib import Path
from typing import List, Optional


def filter_modules_sql(
    sql_content: str,
    modules: Optional[List[str]] = None,
    functions: Optional[List[str]] = None
) -> str:
    """
    Filter modules.sql content by modules and/or functions

    Args:
        sql_content: Full SQL content from modules.sql
        modules: List of module names to include (e.g., ['quadbin', 'tiler'])
        functions: List of function names to include (e.g., ['QUADBIN_POLYFILL'])

    Returns:
        Filtered SQL content containing only matching functions
    """
    if not modules and not functions:
        # No filters - return everything
        return sql_content

    # Pattern to match function definitions
    # Matches: CREATE OR REPLACE FUNCTION schema.FUNCTION_NAME
    function_pattern = r'CREATE\s+OR\s+REPLACE\s+FUNCTION\s+\w+\.(\w+)'

    filtered_functions = []
    current_function_lines = []
    current_function_name = None

    for line in sql_content.split('\n'):
        # Check if this line starts a new function definition
        match = re.search(function_pattern, line, re.IGNORECASE)

        if match:
            # Save previous function if it matches filters
            if current_function_lines and should_include_function(
                current_function_name, modules, functions
            ):
                filtered_functions.extend(current_function_lines)
                filtered_functions.append('')  # Blank line between functions

            # Start tracking new function
            current_function_name = match.group(1)
            current_function_lines = [line]
        else:
            # Continue accumulating lines for current function
            if current_function_lines:
                current_function_lines.append(line)

    # Don't forget the last function
    if current_function_lines and should_include_function(
        current_function_name, modules, functions
    ):
        filtered_functions.extend(current_function_lines)

    return '\n'.join(filtered_functions)


def should_include_function(
    function_name: str,
    modules: Optional[List[str]],
    functions: Optional[List[str]]
) -> bool:
    """
    Determine if a function should be included based on filters

    Priority: specific functions > modules > all

    Args:
        function_name: Name of the function (e.g., 'QUADBIN_POLYFILL')
        modules: List of module names to filter by
        functions: List of specific function names to filter by

    Returns:
        True if function should be included, False otherwise
    """
    if not function_name:
        return False

    # If specific functions are requested, only include those
    if functions:
        return function_name.upper() in [f.upper() for f in functions]

    # If modules are requested, check if function belongs to any module
    if modules:
        for module in modules:
            # Function names follow pattern: MODULE_FUNCTION_NAME
            # e.g., QUADBIN_POLYFILL belongs to 'quadbin' module
            if function_name.upper().startswith(module.upper() + '_'):
                return True
        return False

    # No filters - include everything
    return True


def copy_additional_files(source_cloud_dir: Path, target_cloud_dir: Path):
    """
    Copy additional SQL files from common/ directory

    Note: VERSION.sql is already included in modules.sql (appended by build_modules.js),
    so we skip copying it as a standalone file to avoid redundancy.
    DROP_FUNCTIONS.sql is included as a standalone file for Phase 0.5 of the installer.

    Args:
        source_cloud_dir: Source clouds directory (e.g., clouds/redshift/)
        target_cloud_dir: Target directory in package
    """
    common_dir = source_cloud_dir / 'common'
    if not common_dir.exists():
        return

    # Skip files that are already included in modules.sql
    skip_files = {'VERSION.sql'}

    for sql_file in common_dir.glob('*.sql'):
        if sql_file.name in skip_files:
            print(f'  ⓘ Skipping {sql_file.name} (already in modules.sql)')
            continue

        target_file = target_cloud_dir / sql_file.name
        target_file.write_text(sql_file.read_text())
        print(f'  ✓ Copied {sql_file.name}')


def main():
    parser = argparse.ArgumentParser(
        description='Add clouds SQL to gateway distribution package',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Add all SQL functions
  python add_clouds_sql.py --package-dir=dist/carto-at-redshift-1.0.0 --cloud=redshift

  # Filter by module
  python add_clouds_sql.py --package-dir=dist/pkg --cloud=redshift --modules=quadbin

  # Filter by specific functions
  python add_clouds_sql.py --package-dir=dist/pkg --cloud=redshift \
    --functions=QUADBIN_POLYFILL,QUADBIN_KRING

  # Append private SQL to existing modules.sql
  python add_clouds_sql.py --package-dir=dist/pkg --cloud=redshift \
    --source=../private/clouds/redshift/modules.sql --append
        """
    )

    parser.add_argument(
        '--package-dir',
        required=True,
        type=Path,
        help='Directory of the gateway package to enhance'
    )
    parser.add_argument(
        '--cloud',
        required=True,
        choices=['redshift', 'bigquery', 'snowflake', 'databricks'],
        help='Cloud platform name'
    )
    parser.add_argument(
        '--source',
        type=Path,
        help='Path to source modules.sql (default: clouds/{cloud}/modules/build/modules.sql)'
    )
    parser.add_argument(
        '--modules',
        help='Comma-separated list of modules to include (e.g., quadbin,tiler)'
    )
    parser.add_argument(
        '--functions',
        help='Comma-separated list of functions to include (e.g., QUADBIN_POLYFILL,QUADBIN_KRING)'
    )
    parser.add_argument(
        '--append',
        action='store_true',
        help='Append to existing modules.sql instead of overwriting'
    )

    args = parser.parse_args()

    # Parse filters
    modules = args.modules.split(',') if args.modules else None
    functions = args.functions.split(',') if args.functions else None

    # Determine source SQL path
    if args.source:
        source_sql_path = args.source
    else:
        # Default: look for clouds SQL relative to script location
        script_dir = Path(__file__).parent.parent  # gateway/
        source_sql_path = script_dir.parent / 'clouds' / args.cloud / 'modules' / 'build' / 'modules.sql'

    # Validate source exists
    if not source_sql_path.exists():
        print(f'⚠️  Source SQL not found: {source_sql_path}')
        print(f'   Skipping clouds SQL addition (gateway-only package)')
        return 0

    # Read and filter SQL
    print(f'Reading SQL from: {source_sql_path}')
    sql_content = source_sql_path.read_text()

    # Check if source is from modules/build/modules.sql (already filtered by build_modules.js)
    # If so, skip re-filtering since build_modules.js already applied filters
    is_pre_filtered = 'modules/build/modules.sql' in str(source_sql_path)

    if (modules or functions) and not is_pre_filtered:
        print(f'Filtering SQL...')
        if modules:
            print(f'  Modules: {", ".join(modules)}')
        if functions:
            print(f'  Functions: {", ".join(functions)}')
        filtered_sql = filter_modules_sql(sql_content, modules, functions)
    else:
        if is_pre_filtered and (modules or functions):
            print(f'Using pre-filtered SQL (already filtered by build process)')
        else:
            print(f'Including all SQL functions (no filters)')
        filtered_sql = sql_content

    # Create target directory
    package_dir = args.package_dir
    if not package_dir.exists():
        print(f'Error: Package directory does not exist: {package_dir}')
        return 1

    clouds_dir = package_dir / 'clouds' / args.cloud
    clouds_dir.mkdir(parents=True, exist_ok=True)

    # Write SQL to package
    output_path = clouds_dir / 'modules.sql'

    if args.append and output_path.exists():
        # Append mode (for private functions)
        print(f'Appending SQL to existing modules.sql...')
        existing_content = output_path.read_text()
        output_path.write_text(existing_content + '\n\n' + filtered_sql)
        print(f'✓ Appended clouds SQL to: {output_path}')
    else:
        # Write mode (default)
        output_path.write_text(filtered_sql)
        print(f'✓ Added clouds SQL to: {output_path}')

    # Copy additional files (VERSION.sql, DROP_FUNCTIONS.sql, etc.)
    if not args.append:  # Only copy on first pass, not when appending
        source_cloud_dir = source_sql_path.parent.parent.parent  # ../../../clouds/redshift/
        if source_cloud_dir.exists():
            copy_additional_files(source_cloud_dir, clouds_dir)

    print(f'✓ Package enhanced with clouds SQL')
    return 0


if __name__ == '__main__':
    exit(main())
