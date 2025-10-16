"""
S2FROMUINT64REPR function implementation using shared s2 utilities.

This module imports shared s2 utilities from either:
- lib/s2/ (in deployed Lambda packages - copied by packager)
- _shared/python/s2/ (during local testing)
"""

try:
    # Try importing from lib/s2 (deployed package)
    from lib.s2 import uint64_to_int64
except ImportError:
    # Fall back to shared library (local testing)
    from s2 import uint64_to_int64


__all__ = ["uint64_to_int64"]
