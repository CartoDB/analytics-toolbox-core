from test_utils import run_query


def test_quadbin_bbox():
    """Computes bbox for quadbin"""
    result = run_query('SELECT QUADBIN_BBOX(5209574053332910079)')
    assert result[0][0] == [22.5, -21.9430455334382, 45.0, 0.0]
