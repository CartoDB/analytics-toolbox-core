# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_ispentagon_regular_hexagon():
    """Returns 0 for a regular hexagonal H3 cell."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_ISPENTAGON('8928308280fffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 0


def test_h3_ispentagon_pentagon():
    """Returns 1 for a pentagonal H3 cell."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_ISPENTAGON('821c07fffffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 1


def test_h3_ispentagon_invalid():
    """Returns 0 for an invalid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_ISPENTAGON('ff283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 0


def test_h3_ispentagon_null():
    """Returns 0 for NULL input."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_ISPENTAGON(NULL) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == 0
