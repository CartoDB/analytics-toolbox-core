# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_string_toint():
    """Converts h3 string to h3 int."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_STRING_TOINT('85283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 599686042433355775


def test_h3_string_toint_null():
    """Returns NULL for NULL input."""
    result = run_query('SELECT @@ORA_SCHEMA@@.H3_STRING_TOINT(NULL) FROM DUAL')
    assert len(result) == 1
    assert result[0][0] is None
