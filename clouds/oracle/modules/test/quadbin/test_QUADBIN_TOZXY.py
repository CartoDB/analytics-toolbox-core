# Copyright (c) 2026, CARTO

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


def test_quadbin_tozxy():
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079) FROM DUAL",
        fetch=True,
    )
    row = json.loads(result[0][0])
    assert row['z'] == 4
    assert row['x'] == 9
    assert row['y'] == 8


def test_quadbin_tozxy_z0():
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(5192650370358181887) FROM DUAL",
        fetch=True,
    )
    row = json.loads(result[0][0])
    assert row['z'] == 0
    assert row['x'] == 0
    assert row['y'] == 0


def test_quadbin_tozxy_null():
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(NULL) FROM DUAL",
        fetch=True,
    )
    assert result[0][0] is None


def test_quadbin_tozxy_roundtrip():
    """Verify TOZXY -> FROMZXY roundtrip returns original quadbin."""
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(
            JSON_VALUE(@@ORA_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079), '$.z'),
            JSON_VALUE(@@ORA_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079), '$.x'),
            JSON_VALUE(@@ORA_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079), '$.y')
        ) FROM DUAL
        """,
        fetch=True,
    )
    assert result[0][0] == 5209574053332910079
