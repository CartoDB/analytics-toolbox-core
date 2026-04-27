# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_distance_null_origin():
    """NULL origin returns NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_DISTANCE(NULL, '85283473fffffff') FROM DUAL"
    )
    assert result[0][0] is None


def test_h3_distance_null_destination():
    """NULL destination returns NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_DISTANCE('85283473fffffff', NULL) FROM DUAL"
    )
    assert result[0][0] is None


def test_h3_distance_invalid_origin():
    """Invalid origin returns NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_DISTANCE("
        "'ff283473fffffff', '85283473fffffff') FROM DUAL"
    )
    assert result[0][0] is None


def test_h3_distance_invalid_destination():
    """Invalid destination returns NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_DISTANCE("
        "'85283473fffffff', 'ff283473fffffff') FROM DUAL"
    )
    assert result[0][0] is None


def test_h3_distance_same_cell():
    """Distance from a cell to itself is 0."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_DISTANCE("
        "'8928308280fffff', '8928308280fffff') FROM DUAL"
    )
    assert result[0][0] == 0


def test_h3_distance_valid_inputs():
    """For each ring distance 0-4, verify H3_DISTANCE matches."""
    origin = '8928308280fffff'
    for d in range(5):
        ring = run_query(
            f"SELECT COLUMN_VALUE FROM TABLE("
            f"@@ORA_SCHEMA@@.H3_HEXRING('{origin}', {d}))"
        )
        cells = [r[0] for r in ring]
        for cell in cells:
            result = run_query(
                f"SELECT @@ORA_SCHEMA@@.H3_DISTANCE('{origin}', '{cell}')"
                ' FROM DUAL'
            )
            assert result[0][0] == d, (
                f'Expected distance {d} for {cell}, got {result[0][0]}'
            )
