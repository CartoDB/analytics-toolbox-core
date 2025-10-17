"""
QUADINT_KRING function implementation using shared quadkey utilities.

This module imports shared quadkey utilities from either:
- lib/quadkey/ (in deployed Lambda packages - copied by packager)
- quadkey/ (during local testing from _shared/python/)
"""

try:
    # Try importing from lib/quadkey (deployed package)
    from lib.quadkey import sibling
except ImportError:
    # Fall back to shared library (local testing)
    from quadkey import sibling


__all__ = ["sibling"]
