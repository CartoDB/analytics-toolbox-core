from test_utils import run_query


def test_h3_string_toint():
    """Converts h3 string to h3 int."""
    result = run_query(
        "SELECT @@PG_SCHEMA@@.H3_STRING_TOINT('85283473fffffff') as intid"
    )
    assert len(result) == 1
    assert result[0][0] == 599686042433355775
