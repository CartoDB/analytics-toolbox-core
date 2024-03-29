from test_utils import run_query


def test_quadbin_resolution():
    """Computes resolution from quadbin."""
    result = run_query('SELECT @@PG_SCHEMA@@.QUADBIN_RESOLUTION(5209574053332910079)')
    assert result[0][0] == 4
