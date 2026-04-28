# Copyright (c) 2026, CARTO

import re

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079
TOLERANCE = 1e-6

# Same expected vertices as BigQuery's QUADBIN_BOUNDARY.test.js:
#   POLYGON((22.5 0, 22.5 -21.9430455334382, 45 -21.9430455334382, 45 0, 22.5 0))
EXPECTED_VERTICES = [
    (22.5, 0.0),
    (22.5, -21.9430455334382),
    (45.0, -21.9430455334382),
    (45.0, 0.0),
    (22.5, 0.0),
]


def _parse_polygon_coords(wkt):
    """Extract (lon, lat) pairs from a POLYGON WKT string."""
    match = re.search(r'POLYGON\s*\(\(([^)]+)\)\)', wkt)
    assert match, f'Expected POLYGON WKT, got: {wkt}'
    coords = []
    for pair in match.group(1).split(','):
        lon, lat = pair.strip().split()
        coords.append((float(lon), float(lat)))
    return coords


def test_quadbin_boundary():
    result = run_query(
        f"""
        SELECT TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY(
            @@ORA_SCHEMA@@.QUADBIN_BOUNDARY({QUADBIN_INDEX})
        )) FROM DUAL
        """,
    )

    boundary_wkt = result[0][0]
    assert boundary_wkt is not None
    coords = _parse_polygon_coords(boundary_wkt)
    assert len(coords) == len(EXPECTED_VERTICES), (
        f'Expected {len(EXPECTED_VERTICES)} vertices, got {len(coords)}: {coords}'
    )
    for (lon, lat), (exp_lon, exp_lat) in zip(coords, EXPECTED_VERTICES):
        assert abs(lon - exp_lon) < TOLERANCE, f'lon: got {lon}, expected {exp_lon}'
        assert abs(lat - exp_lat) < TOLERANCE, f'lat: got {lat}, expected {exp_lat}'


def test_quadbin_boundary_srid():
    result = run_query(
        """
        SELECT t.geom.SDO_SRID
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(5209574053332910079) AS geom
            FROM DUAL
        ) t
        """,
    )

    assert result[0][0] == 4326


def test_quadbin_boundary_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(NULL) FROM DUAL',
    )

    assert result[0][0] is None
