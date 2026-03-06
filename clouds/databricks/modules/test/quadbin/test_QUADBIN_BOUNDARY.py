# Copyright (c) 2026, CARTO

import re

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079
TOLERANCE = 1e-6

# Expected boundary coordinates for quadbin 5209574053332910079
EXPECTED_WEST = 22.5
EXPECTED_SOUTH = -21.943045533438166
EXPECTED_EAST = 45.0
EXPECTED_NORTH = 0.0

# Expected vertices: (W S, W N, E N, E S, W S) — closed ring
EXPECTED_COORDS = [
    (EXPECTED_WEST, EXPECTED_SOUTH),
    (EXPECTED_WEST, EXPECTED_NORTH),
    (EXPECTED_EAST, EXPECTED_NORTH),
    (EXPECTED_EAST, EXPECTED_SOUTH),
    (EXPECTED_WEST, EXPECTED_SOUTH),
]


def _parse_wkt_polygon(wkt):
    """Extract coordinate pairs from a WKT POLYGON string."""
    match = re.search(r"POLYGON\(\((.+)\)\)", wkt)
    assert match, f"Not a valid POLYGON WKT: {wkt}"
    pairs = match.group(1).split(",")
    coords = []
    for pair in pairs:
        parts = pair.strip().split()
        coords.append((float(parts[0]), float(parts[1])))
    return coords


def test_quadbin_boundary():
    result = run_query(f"SELECT @@DB_SCHEMA@@.QUADBIN_BOUNDARY({QUADBIN_INDEX})")

    boundary = result[0][0]
    assert boundary is not None

    coords = _parse_wkt_polygon(boundary)
    assert len(coords) == len(EXPECTED_COORDS)
    for (actual_x, actual_y), (expected_x, expected_y) in zip(coords, EXPECTED_COORDS):
        assert abs(actual_x - expected_x) < TOLERANCE
        assert abs(actual_y - expected_y) < TOLERANCE


def test_quadbin_boundary_null():
    result = run_query("SELECT @@DB_SCHEMA@@.QUADBIN_BOUNDARY(NULL)")

    assert result[0][0] is None
