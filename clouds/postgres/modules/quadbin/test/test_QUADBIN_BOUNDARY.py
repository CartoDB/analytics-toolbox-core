from test_utils import run_query


def test_quadbin_boundary():
    """Computes boundary for quadbin."""
    result = run_query(
        'SELECT ST_ASTEXT(@@PG_SCHEMA@@.QUADBIN_BOUNDARY(5209574053332910079))'
    )
    assert (
        result[0][0]
        == 'POLYGON((22.5 -21.9430455334382,22.5 0,45 0,45 -21.9430455334382,22.5 -21.9430455334382))'  # noqa
    )
