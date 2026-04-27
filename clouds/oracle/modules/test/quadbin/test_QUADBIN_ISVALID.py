# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_isvalid():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(5209574053332910079) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(5192650370358181887) FROM DUAL
        """,
    )
    assert result[0][0] == 1
    assert result[1][0] == 1


def test_quadbin_isvalid_invalid():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(0) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(-1) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(1234) FROM DUAL
        """,
    )
    assert result[0][0] == 0
    assert result[1][0] == 0
    assert result[2][0] == 0


def test_quadbin_isvalid_invalid_trailing_bits():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(5209538868960821248) FROM DUAL',
    )
    assert result[0][0] == 0


def test_quadbin_isvalid_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_ISVALID(NULL) FROM DUAL',
    )
    assert result[0][0] == 0
