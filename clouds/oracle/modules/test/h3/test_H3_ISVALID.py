# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_isvalid_valid_cell():
    """Returns 1 for a valid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_ISVALID('85283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 1


def test_h3_isvalid_valid_resolution_0():
    """Returns 1 for a valid resolution-0 H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_ISVALID('8075fffffffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 1


def test_h3_isvalid_invalid_cell():
    """Returns 0 for an invalid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_ISVALID('ff283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 0


def test_h3_isvalid_null():
    """Returns 0 for NULL input."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_ISVALID(NULL) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == 0
