# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromzxy():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(4, 9, 8) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(0, 0, 0) FROM DUAL
        """,
    )
    assert result[0][0] == 5209574053332910079
    assert result[1][0] == 5192650370358181887


def test_quadbin_fromzxy_null():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(NULL, 0, 0) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(0, NULL, 0) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(0, 0, NULL) FROM DUAL
        """,
    )
    assert result[0][0] is None
    assert result[1][0] is None
    assert result[2][0] is None


def test_quadbin_fromzxy_roundtrip():
    """Verify FROMZXY -> TOZXY roundtrip returns original values."""
    result = run_query(
        """SELECT t.zxy.z, t.zxy.x, t.zxy.y
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(
                @@ORA_SCHEMA@@.QUADBIN_FROMZXY(4, 9, 8)
            ) AS zxy
            FROM DUAL
        ) t"""
    )
    z, x, y = result[0]
    assert z == 4
    assert x == 9
    assert y == 8
