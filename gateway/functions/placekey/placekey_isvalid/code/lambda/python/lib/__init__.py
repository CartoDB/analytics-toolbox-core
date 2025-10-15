"""
Function implementation using shared placekey utilities.

This module imports shared placekey utilities from either:
- lib/placekey/ (in deployed Lambda packages - copied by packager)
- _shared/python/placekey/ (during local testing)
"""

try:
    # Try importing from lib/placekey (deployed package)
    from lib.placekey import placekey_is_valid
except ImportError:
    # Fall back to shared library (local testing)
    from placekey import placekey_is_valid


def placekey_isvalid(placekey):
    """
    Check if a placekey is valid.

    Args:
        placekey: Placekey string

    Returns:
        True if valid, False otherwise
    """
    return placekey_is_valid(placekey)
