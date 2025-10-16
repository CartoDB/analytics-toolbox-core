"""
S2BOUNDARY function implementation using shared s2 utilities.

This module imports shared s2 utilities from either:
- lib/s2/ (in deployed Lambda packages - copied by packager)
- _shared/python/s2/ (during local testing)
"""

try:
    # Try importing from lib/s2 (deployed package)
    from lib.s2 import get_cell_boundary
except ImportError:
    # Fall back to shared library (local testing)
    from s2 import get_cell_boundary


__all__ = ["get_cell_boundary"]
