# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_int_tostring():
    """Converts h3 int to h3 string."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_INT_TOSTRING(599686042433355775) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '85283473fffffff'


def test_h3_int_tostring_null():
    """Returns NULL for NULL input."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_INT_TOSTRING(NULL) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None
