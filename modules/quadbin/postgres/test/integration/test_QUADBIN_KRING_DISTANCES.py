from test_utils import run_query


def index_key(item):
    return item['index']


def test_quadbin_kring_distances():
    """Computes kring"""
    result = run_query('SELECT QUADBIN_KRING_DISTANCES(5209574053332910079, 1)')
    expected = sorted(
        [
            {'index': 5208043533147045887, 'distance': 1},
            {'index': 5209556461146865663, 'distance': 1},
            {'index': 5209591645518954495, 'distance': 1},
            {'index': 5208061125333090303, 'distance': 1},
            {'index': 5209574053332910079, 'distance': 0},
            {'index': 5209609237704998911, 'distance': 1},
            {'index': 5208113901891223551, 'distance': 1},
            {'index': 5209626829891043327, 'distance': 1},
            {'index': 5209662014263132159, 'distance': 1},
        ],
        key=index_key,
    )
    assert sorted(result[0][0], key=index_key) == expected
