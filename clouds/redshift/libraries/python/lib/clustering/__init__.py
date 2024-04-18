PRECISION = 15


def load_geom(geom):
    from geojson import loads
    import json

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geom = json.dumps(_geom)
    return loads(geom)


def remove_duplicated_coords(arr):
    import numpy as np

    unique_rows = []
    for row in arr:
        if not any(np.array_equal(row, unique_row) for unique_row in unique_rows):
            unique_rows.append(row)
    return np.array(unique_rows)


def reorder_coords(coords):
    import numpy as np

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

    # Convert lists to NumPy arrays for sorting
    unique_coords = np.array(unique_coords)
    duplicated_coords = np.array(duplicated_coords)

    # Sort unique coordinates lexicographically if not empty
    if unique_coords.size > 0:
        if duplicated_coords.size > 0:
            # Concatenate unique and duplicated coordinates
            return np.concatenate((unique_coords, duplicated_coords))
        else:
            return unique_coords
    else:
        # Sort duplicated coordinates lexicographically if not empty
        if duplicated_coords.size > 0:
            return duplicated_coords
        else:
            # This should never happen, so just returning the input
            return coords


def count_distinct_coords(coords):
    import numpy as np

    count_map = {}
    for coord in coords:
        coord_str = tuple(coord)
        count_map[coord_str] = count_map.get(coord_str, 0) + 1
    return len(count_map)


def clusterkmeanstable(geom, k):
    from .kmeans import KMeans
    import json
    import numpy as np

    geom = load_geom(geom)
    points = geom['_coords']
    coords = reorder_coords(
        np.array([[points[i], points[i + 1]] for i in range(0, len(points) - 1, 2)])
    )
    # k cannot be greater than the number of distinct coordinates
    k = min(k, count_distinct_coords(coords))

    cluster_idxs, centers, loss = KMeans()(coords, k)

    return json.dumps(
        [{'c': cluster_idxs[idx], 'i': idx + 1} for idx, point in enumerate(coords)]
    )


def clusterkmeans(geom, k):
    from .kmeans import KMeans
    import geojson
    import numpy as np

    geom = load_geom(geom)
    coords = []
    if geom.type != 'MultiPoint':
        raise Exception('Invalid operation: Input points parameter must be MultiPoint.')
    else:
        coords = reorder_coords(np.array(list(geojson.utils.coords(geom))))
    # k cannot be greater than the number of distinct coordinates
    k = min(k, count_distinct_coords(coords))

    cluster_idxs, centers, loss = KMeans()(coords, k)
    return geojson.dumps(
        [
            {
                'cluster': cluster_idxs[idx],
                'geom': {'coordinates': point.tolist(), 'type': 'Point'},
            }
            for idx, point in enumerate(coords)
        ]
    )
