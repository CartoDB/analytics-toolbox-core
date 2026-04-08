# Copyright (c) 2026, CARTO

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


TOLERANCE = 1e-6

QUADBIN_INDEX = 5209574053332910079
EXPECTED_WEST = 22.5
EXPECTED_SOUTH = -21.943045533438166
EXPECTED_EAST = 45.0
EXPECTED_NORTH = 0.0


def test_quadbin_bbox():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_BBOX(5209574053332910079) FROM DUAL',
        fetch=True,
    )

    raw = result[0][0]
    bbox = json.loads(raw)
    assert len(bbox) == 4
    assert abs(bbox[0] - EXPECTED_WEST) < TOLERANCE
    assert abs(bbox[1] - EXPECTED_SOUTH) < TOLERANCE
    assert abs(bbox[2] - EXPECTED_EAST) < TOLERANCE
    assert abs(bbox[3] - EXPECTED_NORTH) < TOLERANCE


def test_quadbin_bbox_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_BBOX(NULL) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None
