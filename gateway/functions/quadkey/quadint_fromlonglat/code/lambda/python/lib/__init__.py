"""
QUADINT_FROMLONGLAT function implementation using shared quadkey utilities.

This module imports shared quadkey utilities from either:
- lib/quadkey/ (in deployed Lambda packages - copied by packager)
- quadkey/ (during local testing from _shared/python/)
"""

try:
    # Try importing from lib/quadkey (deployed package)
    from lib.quadkey import quadint_from_zxy, clip_number
except ImportError:
    # Fall back to shared library (local testing)
    from quadkey import quadint_from_zxy, clip_number


__all__ = ["quadint_from_zxy", "clip_number"]
