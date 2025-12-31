"""
Shared quadkey utilities for CARTO Analytics Toolbox
Contains core quadkey/quadint conversion functions
"""


def quadint_from_zxy(z, x, y):
    """Convert z, x, y tile coordinates to quadint format."""
    if z < 0 or z > 29:
        return None

    quadint = y
    quadint <<= z
    quadint |= x
    quadint <<= 5
    quadint |= z
    return quadint


def zxy_from_quadint(quadint):
    """Convert quadint to z, x, y tile coordinates."""
    z = quadint & 31
    x = (quadint >> 5) & ((1 << z) - 1)
    y = quadint >> (z + 5)
    return {"z": z, "x": x, "y": y}


def clip_number(num, a, b):
    """Clip a number to be within [a, b] range."""
    return max(min(num, b), a)


def sibling(quadint, direction):
    """
    Get the sibling quadint in the specified direction.

    Args:
        quadint: The origin quadint
        direction: One of 'left', 'right', 'up', 'down'

    Returns:
        The sibling quadint in the specified direction
    """
    if quadint == 0:
        return 0
    direction = direction.lower()
    if direction not in ["left", "right", "up", "down"]:
        raise Exception("Wrong direction argument passed to sibling")

    tile = zxy_from_quadint(quadint)
    z = tile["z"]
    x = tile["x"]
    y = tile["y"]
    tiles_per_level = 2 << (z - 1)
    if direction == "left":
        x = x - 1 if x > 0 else tiles_per_level - 1

    if direction == "right":
        x = x + 1 if x < tiles_per_level - 1 else 0

    if direction == "up":
        y = y - 1 if y > 0 else tiles_per_level - 1

    if direction == "down":
        y = y + 1 if y < tiles_per_level - 1 else 0

    return quadint_from_zxy(z, x, y)
