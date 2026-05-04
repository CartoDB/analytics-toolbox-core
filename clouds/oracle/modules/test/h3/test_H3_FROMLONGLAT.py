# Copyright (c) 2026, CARTO
from test_utils import run_query


def test_h3_fromlonglat_basic():
    """Returns correct H3 index for a known location."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238, 37.3615593, 5)' ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '85283473fffffff'


def test_h3_fromlonglat_second_location():
    """Returns correct H3 index for a second known location."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-164.991559, 30.943387, 5)' ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '8547732ffffffff'


def test_h3_fromlonglat_resolution_15():
    """Returns correct H3 index at maximum resolution."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT('
        '71.52790329909925, 46.04189431883772, 15) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '8f2000000000000'


def test_h3_fromlonglat_null_longitude():
    """Returns NULL when longitude is NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(NULL, 37.3615593, 5)' ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromlonglat_null_latitude():
    """Returns NULL when latitude is NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238, NULL, 5)' ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromlonglat_null_resolution():
    """Returns NULL when resolution is NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238, 37.3615593, NULL)'
        ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromlonglat_world_wrapping_longitude():
    """Longitude offset by +360 should produce the same cell.."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238 + 360,'
        ' 37.3615593, 5) FROM DUAL'
    )
    assert result[0][0] == '85283473fffffff'


def test_h3_fromlonglat_world_wrapping_latitude():
    """Latitude offset by +360 should produce the same cell.."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238,'
        ' 37.3615593 + 360, 5) FROM DUAL'
    )
    assert result[0][0] == '85283473fffffff'


def test_h3_fromlonglat_invalid_resolution_negative():
    """Returns NULL for negative resolution."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238, 37.3615593, -1)'
        ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_fromlonglat_invalid_resolution_too_high():
    """Returns NULL for resolution above 15."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(-122.0553238, 37.3615593, 20)'
        ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None
