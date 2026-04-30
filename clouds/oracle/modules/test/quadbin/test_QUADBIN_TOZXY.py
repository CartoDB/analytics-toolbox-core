# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_tozxy():
    result = run_query(
        """SELECT t.zxy.z, t.zxy.x, t.zxy.y
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079) AS zxy
            FROM DUAL
        ) t"""
    )
    z, x, y = result[0]
    assert z == 4
    assert x == 9
    assert y == 8


def test_quadbin_tozxy_z0():
    result = run_query(
        """SELECT t.zxy.z, t.zxy.x, t.zxy.y
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(5192650370358181887) AS zxy
            FROM DUAL
        ) t"""
    )
    z, x, y = result[0]
    assert z == 0
    assert x == 0
    assert y == 0


def test_quadbin_tozxy_null():
    result = run_query(
        """SELECT t.zxy.z
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(NULL) AS zxy FROM DUAL
        ) t"""
    )
    assert result[0][0] is None


def test_quadbin_tozxy_roundtrip():
    """Verify TOZXY -> FROMZXY roundtrip returns original quadbin."""
    result = run_query(
        """SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(t.zxy.z, t.zxy.x, t.zxy.y)
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079) AS zxy
            FROM DUAL
        ) t"""
    )
    assert result[0][0] == 5209574053332910079
