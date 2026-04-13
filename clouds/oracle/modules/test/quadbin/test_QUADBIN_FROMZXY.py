# Copyright (c) 2026, CARTO

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


def test_quadbin_fromzxy():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(4, 9, 8) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(0, 0, 0) FROM DUAL
        """,
        fetch=True,
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
        fetch=True,
    )
    assert result[0][0] is None
    assert result[1][0] is None
    assert result[2][0] is None


def test_quadbin_fromzxy_roundtrip():
    """Verify FROMZXY -> TOZXY roundtrip returns original values."""
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_TOZXY(
            @@ORA_SCHEMA@@.QUADBIN_FROMZXY(4, 9, 8)
        ) FROM DUAL
        """,
        fetch=True,
    )
    import json
    row = json.loads(result[0][0])
    assert row['z'] == 4
    assert row['x'] == 9
    assert row['y'] == 8
