# Copyright (c) 2026, CARTO

import json

from test_utils import run_query


TOLERANCE = 1e-6


def test_quadbin_center():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_CENTER(5209574053332910079)')

    raw = result[0][0]
    center = json.loads(raw) if isinstance(raw, str) else raw
    assert abs(center[0] - 33.75) < TOLERANCE
    assert abs(center[1] - (-11.178401873711792)) < TOLERANCE


def test_quadbin_center_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_CENTER(NULL)')

    assert result[0][0] is None
