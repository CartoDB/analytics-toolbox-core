# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_resolution_5():
    """Returns resolution 5 for a resolution-5 H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('85283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 5


def test_h3_resolution_1():
    """Returns resolution 1 for a resolution-1 H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('81623ffffffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == 1


def test_h3_resolution_invalid():
    """Returns NULL for an invalid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('ff283473fffffff') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_resolution_null():
    """Returns NULL for NULL input."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_RESOLUTION(NULL) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None
