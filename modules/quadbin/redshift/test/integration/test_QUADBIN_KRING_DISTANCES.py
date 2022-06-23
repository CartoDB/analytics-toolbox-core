from test_utils import run_query
import json


def test_quadbin_kring_distances():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_KRING_DISTANCES(
            5209574053332910079,
            1) AS output"""
    )

    assert len(result[0]) == 1
    assert json.loads(result[0][0]) == [
        {'index': 5208043533147045887, 'distance': 1},
        {'index': 5208061125333090303, 'distance': 1},
        {'index': 5208113901891223551, 'distance': 1},
        {'index': 5209556461146865663, 'distance': 1},
        {'index': 5209574053332910079, 'distance': 0},
        {'index': 5209626829891043327, 'distance': 1},
        {'index': 5209591645518954495, 'distance': 1},
        {'index': 5209609237704998911, 'distance': 1},
        {'index': 5209662014263132159, 'distance': 1},
    ]
