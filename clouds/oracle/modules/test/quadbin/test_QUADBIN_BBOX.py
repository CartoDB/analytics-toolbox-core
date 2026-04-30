# Copyright (c) 2026, CARTO

from test_utils import run_query


TOLERANCE = 1e-6

QUADBIN_INDEX = 5209574053332910079
EXPECTED_WEST = 22.5
EXPECTED_SOUTH = -21.943045533438166
EXPECTED_EAST = 45.0
EXPECTED_NORTH = 0.0


def test_quadbin_bbox():
    result = run_query(
        f"""SELECT t.bbox.west, t.bbox.south, t.bbox.east, t.bbox.north
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_BBOX({QUADBIN_INDEX}) AS bbox
            FROM DUAL
        ) t"""
    )

    west, south, east, north = result[0]
    assert abs(west - EXPECTED_WEST) < TOLERANCE
    assert abs(south - EXPECTED_SOUTH) < TOLERANCE
    assert abs(east - EXPECTED_EAST) < TOLERANCE
    assert abs(north - EXPECTED_NORTH) < TOLERANCE


def test_quadbin_bbox_null():
    result = run_query(
        """SELECT t.bbox.west
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_BBOX(NULL) AS bbox FROM DUAL
        ) t"""
    )

    assert result[0][0] is None
