"""
PLACEKEY_ASH3 function implementation.

This module imports shared utilities from lib/
"""

from lib.placekey import placekey_to_h3, placekey_is_valid


def placekey_ash3(placekey):
    """
    Convert a Placekey to H3 index.

    Args:
        placekey: Placekey string

    Returns:
        H3 index string or None if invalid
    """
    if not placekey_is_valid(placekey):
        return None
    return placekey_to_h3(placekey)
