# Copyright (c) 2026, CARTO
from test_utils import run_query


COORDINATE_TOLERANCE = 1e-4


def test_h3_center_null():
    """Returns NULL for NULL input."""
    result = run_query('SELECT @@ORA_SCHEMA@@.H3_CENTER(NULL) FROM DUAL')
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_center_invalid():
    """Returns NULL for an invalid H3 index."""
    result = run_query("SELECT @@ORA_SCHEMA@@.H3_CENTER('ff283473fffffff') FROM DUAL")
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_center_resolution_5():
    """Returns correct center point for a resolution-5 H3 index."""
    result = run_query(
        'SELECT'
        ' t.center.SDO_POINT.X AS lon,'
        ' t.center.SDO_POINT.Y AS lat'
        " FROM (SELECT @@ORA_SCHEMA@@.H3_CENTER('85283473fffffff')"
        ' AS center FROM DUAL) t'
    )
    assert len(result) == 1
    lon, lat = result[0]
    expected_lon = -121.9763759725512
    expected_lat = 37.34579337536848
    assert abs(lon - expected_lon) < COORDINATE_TOLERANCE
    assert abs(lat - expected_lat) < COORDINATE_TOLERANCE


def test_h3_center_resolution_1():
    """Returns correct center point for a resolution-1 H3 index."""
    result = run_query(
        'SELECT'
        ' t.center.SDO_POINT.X AS lon,'
        ' t.center.SDO_POINT.Y AS lat'
        " FROM (SELECT @@ORA_SCHEMA@@.H3_CENTER('81623ffffffffff')"
        ' AS center FROM DUAL) t'
    )
    assert len(result) == 1
    lon, lat = result[0]
    expected_lon = 58.1577058395726
    expected_lat = 10.447345187511
    assert abs(lon - expected_lon) < COORDINATE_TOLERANCE
    assert abs(lat - expected_lat) < COORDINATE_TOLERANCE


def test_h3_center_srid_4326():
    """Returns a geometry with SRID 4326."""
    result = run_query(
        'SELECT t.center.SDO_SRID FROM'
        " (SELECT @@ORA_SCHEMA@@.H3_CENTER('85283473fffffff')"
        ' AS center FROM DUAL) t'
    )
    assert len(result) == 1
    assert result[0][0] == 4326
