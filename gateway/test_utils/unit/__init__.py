"""
Language-specific unit test utilities.

Each language has its own module:
- python.py: Python Lambda/Cloud Run function utilities
- javascript.py: JavaScript/Node.js function utilities (future)
- go.py: Go function utilities (future)
"""

# Re-export Python utilities for convenience
from .python import load_function_module  # noqa: F401
