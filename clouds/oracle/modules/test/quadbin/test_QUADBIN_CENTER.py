# Copyright (c) 2026, CARTO

from test_utils import run_query


TOLERANCE = 1e-6

QUADBIN_INDEX = 5209574053332910079
EXPECTED_LON = 33.75
EXPECTED_LAT = -11.178401873711792


def test_quadbin_center():
    result = run_query(
        """
        SELECT
            t.geom.SDO_POINT.X,
            t.geom.SDO_POINT.Y
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_CENTER(5209574053332910079) AS geom
            FROM DUAL
        ) t
        """,
    )

    assert abs(result[0][0] - EXPECTED_LON) < TOLERANCE
    assert abs(result[0][1] - EXPECTED_LAT) < TOLERANCE


def test_quadbin_center_srid():
    result = run_query(
        """
        SELECT t.geom.SDO_SRID
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_CENTER(5209574053332910079) AS geom
            FROM DUAL
        ) t
        """,
    )

    assert result[0][0] == 4326


def test_quadbin_center_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_CENTER(NULL) FROM DUAL',
    )

    assert result[0][0] is None
