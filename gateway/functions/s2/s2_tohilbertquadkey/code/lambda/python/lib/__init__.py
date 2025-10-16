"""
S2TOHILBERTQUADKEY function implementation using shared s2 utilities.

This module imports shared s2 utilities from either:
- lib/s2/ (in deployed Lambda packages - copied by packager)
- _shared/python/s2/ (during local testing)
"""

try:
    # Try importing from lib/s2 (deployed package)
    from lib.s2 import id_to_hilbert_quadkey
except ImportError:
    # Fall back to shared library (local testing)
    from s2 import id_to_hilbert_quadkey


__all__ = ["id_to_hilbert_quadkey"]
