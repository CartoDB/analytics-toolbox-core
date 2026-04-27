# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_resolution():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_RESOLUTION(5209574053332910079) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_RESOLUTION(5192650370358181887) FROM DUAL
        """,
    )
    assert result[0][0] == 4
    assert result[1][0] == 0


def test_quadbin_resolution_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_RESOLUTION(NULL) FROM DUAL',
    )
    assert result[0][0] is None
