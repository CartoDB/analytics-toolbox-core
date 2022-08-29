from test_utils import run_query


def test_quadbin_bbox():
    """Computes bbox for quadbin."""
    result = run_query('SELECT @@PG_SCHEMA@@.QUADBIN_BBOX(5209574053332910079)')
    assert result[0][0] == [22.5, -21.943045533438166, 45.0, 0.0]
