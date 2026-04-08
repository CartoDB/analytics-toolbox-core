# Copyright (c) 2026, CARTO

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


QUADBIN_INDEX = 5209574053332910079


def test_quadbin_boundary():
    result = run_query(
        """
        SELECT TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY(
            @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(5209574053332910079)
        )) FROM DUAL
        """,
        fetch=True,
    )

    boundary_wkt = result[0][0]
    assert boundary_wkt is not None
    assert 'POLYGON' in boundary_wkt


def test_quadbin_boundary_srid():
    result = run_query(
        """
        SELECT t.geom.SDO_SRID
        FROM (
            SELECT @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(5209574053332910079) AS geom
            FROM DUAL
        ) t
        """,
        fetch=True,
    )

    assert result[0][0] == 4326


def test_quadbin_boundary_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(NULL) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None
