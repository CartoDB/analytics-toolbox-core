from .placekey import placekey_is_valid


def placekey_isvalid(placekey):
    """
    Check if a Placekey is valid.

    Args:
        placekey: Placekey string

    Returns:
        Boolean indicating if the placekey is valid
    """
    return placekey_is_valid(placekey)
