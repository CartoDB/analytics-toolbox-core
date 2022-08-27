from test_utils import run_query


def test_quadbin_int_tostring():
    """Computes string quadbin."""
    result = run_query(
        'SELECT @@PG_SCHEMA@@.__QUADBIN_INT_TOSTRING(5209574053332910079)'
    )
    assert result[0][0] == '484c1fffffffffff'
