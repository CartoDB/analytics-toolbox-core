from test_utils import run_query


def test_quadbin_fromquadint():
    """Computes quadbin from quadint."""
    result = run_query('SELECT @@PG_SCHEMA@@.__QUADBIN_FROMQUADINT(4388)')
    assert result[0][0] == 5209574053332910079
