from test_utils import run_query


def test_h3_int_tostring():
    """Converts h3 int to h3 string."""
    result = run_query(
        'SELECT @@PG_SCHEMA@@.H3_INT_TOSTRING(599686042433355775) as strid'
    )
    assert len(result) == 1
    assert result[0][0] == '85283473fffffff'
