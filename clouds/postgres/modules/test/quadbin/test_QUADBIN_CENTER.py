from test_utils import run_query


def test_quadbin_center():
    """Computes center for quadbin."""
    result = run_query(
        'SELECT ST_ASTEXT(@@PG_SCHEMA@@.QUADBIN_CENTER(5209574053332910079))'
    )
    assert result[0][0] == 'POINT(33.75 -11.178401873711776)'
