import numpy as np

PRECISION = 15


def load_geom(geom):
    from geojson import loads
    import json

    _geom = json.loads(geom)
    _geom["precision"] = PRECISION
    geom = json.dumps(_geom)
    return loads(geom)


def reorder_coords(coords):
    """
    Reorder coordinates to place unique coordinates first, then duplicates.

    Args:
        coords: numpy array of coordinates

    Returns:
        Reordered numpy array
    """
    unique_coords = []
    duplicated_coords = []

    # Split the array into unique and duplicated coordinates
    count_map = {}
    for coord in coords:
        coord_str = tuple(coord)
        if coord_str not in count_map:
            count_map[coord_str] = 1
            unique_coords.append(coord)
        else:
            count_map[coord_str] += 1
            duplicated_coords.append(coord)

    # Convert lists to NumPy arrays
    unique_coords = np.array(unique_coords)
    duplicated_coords = (
        np.array(duplicated_coords) if duplicated_coords else np.array([])
    )

    if unique_coords.size > 0:
        if duplicated_coords.size > 0:
            return np.concatenate((unique_coords, duplicated_coords))
        else:
            return unique_coords
    else:
        if duplicated_coords.size > 0:
            return duplicated_coords
        else:
            return coords


def count_distinct_coords(coords):
    """
    Count distinct coordinates in array.

    Args:
        coords: numpy array of coordinates

    Returns:
        Number of distinct coordinates
    """
    count_map = {}
    for coord in coords:
        coord_str = tuple(coord)
        count_map[coord_str] = count_map.get(coord_str, 0) + 1
    return len(count_map)
