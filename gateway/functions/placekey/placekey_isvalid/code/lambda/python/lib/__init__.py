"""
Function implementation using shared placekey utilities.

This module imports shared utilities from lib/
"""

from lib.placekey import placekey_is_valid


def placekey_isvalid(placekey):
    """
    Check if a placekey is valid.

    Args:
        placekey: Placekey string

    Returns:
        True if valid, False otherwise
    """
    return placekey_is_valid(placekey)
