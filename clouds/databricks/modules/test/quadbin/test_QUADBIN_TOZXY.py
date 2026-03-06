# Copyright (c) 2026, CARTO

import json

from test_utils import run_query


def test_quadbin_tozxy():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(5209574053332910079)')

    raw = result[0][0]
    row = json.loads(raw) if isinstance(raw, str) else raw
    assert row['z'] == 4
    assert row['x'] == 9
    assert row['y'] == 8


def test_quadbin_tozxy_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(NULL)')

    assert result[0][0] is None
