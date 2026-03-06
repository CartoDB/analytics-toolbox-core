# Copyright (c) 2026, CARTO

import json

from test_utils import run_query


TOLERANCE = 1e-6


def test_quadbin_bbox():
    result = run_query("SELECT @@DB_SCHEMA@@.QUADBIN_BBOX(5209574053332910079)")

    raw = result[0][0]
    bbox = json.loads(raw) if isinstance(raw, str) else raw
    assert len(bbox) == 4
    assert abs(bbox[0] - 22.5) < TOLERANCE
    assert abs(bbox[1] - (-21.943045533438166)) < TOLERANCE
    assert abs(bbox[2] - 45.0) < TOLERANCE
    assert abs(bbox[3] - 0.0) < TOLERANCE


def test_quadbin_bbox_null():
    result = run_query("SELECT @@DB_SCHEMA@@.QUADBIN_BBOX(NULL)")

    assert result[0][0] is None
