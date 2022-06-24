from test_utils import run_query


def test_quadbin_kring():
    """Computes kring"""
    result = run_query('SELECT QUADBIN_KRING(5209574053332910079, 1)')
    expected = sorted(
        [
            5208043533147045887,
            5209556461146865663,
            5209591645518954495,
            5208061125333090303,
            5209574053332910079,
            5209609237704998911,
            5208113901891223551,
            5209626829891043327,
            5209662014263132159,
        ]
    )
    assert sorted(result[0][0]) == expected
