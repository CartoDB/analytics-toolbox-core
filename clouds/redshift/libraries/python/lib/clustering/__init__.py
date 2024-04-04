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

def clusterkmeanstable(geom, k):
    from .kmeans import KMeans
    import json
    import numpy as np

    geom = load_geom(geom)
    points = geom['_coords']
    coords = np.array(
        [[points[i], points[i + 1]] for i in range(0, len(points) - 1, 2)]
    )

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
        coords = remove_duplicated_coords(np.array(list(geojson.utils.coords(geom))))
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
