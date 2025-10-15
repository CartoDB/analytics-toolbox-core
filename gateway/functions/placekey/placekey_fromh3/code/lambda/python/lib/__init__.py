"""
Function implementation using shared placekey utilities.

This module imports shared placekey utilities from either:
- lib/placekey/ (in deployed Lambda packages - copied by packager)
- _shared/python/placekey/ (during local testing)
"""

try:
    # Try importing from lib/placekey (deployed package)
    from lib.placekey import h3_to_placekey, h3_is_valid
except ImportError:
    # Fall back to shared library (local testing)
    from placekey import h3_to_placekey, h3_is_valid


def placekey_fromh3(h3_index):
    """
    Convert an H3 index to Placekey.

    Args:
        h3_index: H3 index string

    Returns:
        Placekey string or None if invalid
    """
    if not h3_is_valid(h3_index):
        return None
    return h3_to_placekey(h3_index)
