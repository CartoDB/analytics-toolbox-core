"""
ST_CENTERMEAN helper.

Imports center_mean from shared transformations library (clouds code).
"""

try:
    # Try importing from lib/transformations (deployed package)
    from lib.transformations import center_mean
except ImportError:
    # Fall back to shared library (local testing)
    from transformations import center_mean


__all__ = ["center_mean"]
