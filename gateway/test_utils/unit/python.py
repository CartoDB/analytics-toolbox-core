"""
Python-specific unit test utilities for gateway functions.

These utilities help load and test Python Lambda/Cloud Run functions
in isolation, regardless of which cloud platform they target.

For other languages, see:
- javascript.py: JavaScript/Node.js utilities (future)
- go.py: Go utilities (future)
"""

import sys
import importlib.util
from pathlib import Path


# Note: setup_shared_libraries_path() has been removed.
# Tests now use the build/ directory which mirrors the actual deployment structure.
# Run `make build` before running tests.


def load_function_module(test_file_path, import_spec=None):
    """
    Load a function's lib module and handler for unit testing.

    This loads the function from the build/ directory which mirrors the actual
    deployment structure with shared libraries already copied into lib/.

    Args:
        test_file_path: Path to the test file (usually __file__ from the test)
        import_spec: Dict specifying what to import from lib or handler, e.g.:
            {
                'from_lib': ['function_name', 'HelperClass'],
                'from_lib_module': {
                    'helper': ['helper_func1', 'helper_func2'],
                    'placekey': ['placekey_is_valid']
                },
                'from_handler': ['helper_func', 'internal_function']
            }

    Returns:
        Dict with 'lambda_handler' and any requested imports

    Example:
        # In your test file:
        from test_utils.unit import load_function_module
        # Or explicitly: from test_utils.unit.python import load_function_module

        imports = load_function_module(__file__, {
            'from_lib': ['clusterkmeans', 'KMeans'],
            'from_lib_module': {
                'helper': ['reorder_coords', 'count_distinct_coords']
            },
            'from_handler': ['internal_helper']
        })

        clusterkmeans = imports['clusterkmeans']
        KMeans = imports['KMeans']
        lambda_handler = imports['lambda_handler']
        internal_helper = imports['internal_helper']
    """
    test_path = Path(test_file_path)
    # Original function root (in source)
    function_root = test_path.parent.parent.parent

    # Find gateway root and build directory
    gateway_root = function_root.parent.parent.parent
    build_root = gateway_root / "build"

    # Determine function module and name from path
    # Path structure: functions/<module>/<function_name>/tests/unit/test_*.py
    parts = test_path.parts
    functions_idx = parts.index("functions")
    module_name = parts[functions_idx + 1]
    function_name = parts[functions_idx + 2]

    # Use build directory - it must exist (run `make build` first)
    code_dir = build_root / "functions" / module_name / function_name / "code" / "lambda" / "python"

    if not code_dir.exists():
        raise FileNotFoundError(
            f"Build directory not found: {code_dir}\n"
            f"Run 'make build' before running tests to create the build directory."
        )

    # Save and clear all lib.* modules to avoid conflicts
    original_sys_path = sys.path.copy()
    saved_lib_modules = {
        k: v for k, v in sys.modules.items() if k == "lib" or k.startswith("lib.")
    }
    for key in list(saved_lib_modules.keys()):
        sys.modules.pop(key, None)

    result = {}

    # Add function code dir to path (shared libs already in lib/)
    sys.path.insert(0, str(code_dir))

    try:
        # Import from lib
        if import_spec and "from_lib" in import_spec:
            lib_module = __import__("lib")
            for name in import_spec["from_lib"]:
                result[name] = getattr(lib_module, name)

        # Import from lib.submodule
        if import_spec and "from_lib_module" in import_spec:
            for module_name, names in import_spec["from_lib_module"].items():
                submodule = __import__(f"lib.{module_name}", fromlist=names)
                for name in names:
                    result[name] = getattr(submodule, name)

        # Load the handler module
        handler_path = code_dir / "handler.py"
        spec = importlib.util.spec_from_file_location("handler", handler_path)
        handler_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(handler_module)
        result["lambda_handler"] = handler_module.lambda_handler

        # Import additional functions from handler if requested
        if import_spec and "from_handler" in import_spec:
            for name in import_spec["from_handler"]:
                result[name] = getattr(handler_module, name)

    finally:
        # Restore sys.path and clear our lib modules
        sys.path[:] = original_sys_path
        for key in list(sys.modules.keys()):
            if key == "lib" or key.startswith("lib."):
                sys.modules.pop(key, None)
        sys.modules.update(saved_lib_modules)

    return result
