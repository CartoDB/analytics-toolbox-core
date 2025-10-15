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


def load_function_module(test_file_path, import_spec=None):
    """
    Load a function's lib module and handler for unit testing.

    This handles the complex path setup and module isolation needed to test
    gateway functions that have lib/ subdirectories.

    Args:
        test_file_path: Path to the test file (usually __file__ from the test)
        import_spec: Dict specifying what to import from lib, e.g.:
            {
                'from_lib': ['function_name', 'HelperClass'],
                'from_lib_module': {
                    'helper': ['helper_func1', 'helper_func2'],
                    'placekey': ['placekey_is_valid']
                }
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
            }
        })

        clusterkmeans = imports['clusterkmeans']
        KMeans = imports['KMeans']
        lambda_handler = imports['lambda_handler']
    """
    test_path = Path(test_file_path)
    function_root = test_path.parent.parent.parent
    code_dir = function_root / "code" / "lambda" / "python"

    # Save and clear all lib.* modules to avoid conflicts
    original_sys_path = sys.path.copy()
    saved_lib_modules = {
        k: v for k, v in sys.modules.items() if k == "lib" or k.startswith("lib.")
    }
    for key in list(saved_lib_modules.keys()):
        sys.modules.pop(key, None)

    result = {}

    sys.path.insert(0, str(code_dir))
    try:
        # Import from lib
        if import_spec and 'from_lib' in import_spec:
            lib_module = __import__('lib')
            for name in import_spec['from_lib']:
                result[name] = getattr(lib_module, name)

        # Import from lib.submodule
        if import_spec and 'from_lib_module' in import_spec:
            for module_name, names in import_spec['from_lib_module'].items():
                submodule = __import__(f'lib.{module_name}', fromlist=names)
                for name in names:
                    result[name] = getattr(submodule, name)

        # Load the handler module
        handler_path = code_dir / "handler.py"
        spec = importlib.util.spec_from_file_location("handler", handler_path)
        handler_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(handler_module)
        result['lambda_handler'] = handler_module.lambda_handler

    finally:
        # Restore sys.path and clear our lib modules
        sys.path[:] = original_sys_path
        for key in list(sys.modules.keys()):
            if key == "lib" or key.startswith("lib."):
                sys.modules.pop(key, None)
        sys.modules.update(saved_lib_modules)

    return result
