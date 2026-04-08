# Copyright (c) 2026, CARTO

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


def test_quadbin_distance():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_DISTANCE('
        '    5207251884775047167, 5207128739472736255'
        ') FROM DUAL',
        fetch=True,
    )

    assert result[0][0] == 1


def test_quadbin_distance_same_index():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_DISTANCE('
        '    5209574053332910079, 5209574053332910079'
        ') FROM DUAL',
        fetch=True,
    )

    assert result[0][0] == 0


def test_quadbin_distance_different_resolution():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_DISTANCE('
        '    5209574053332910079, 5205105638077628415'
        ') FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None


def test_quadbin_distance_null():
    result = run_query(
        """
        SELECT
            @@ORA_SCHEMA@@.QUADBIN_DISTANCE(NULL, 5207128739472736255),
            @@ORA_SCHEMA@@.QUADBIN_DISTANCE(5207251884775047167, NULL)
        FROM DUAL
        """,
        fetch=True,
    )

    assert result[0][0] is None
    assert result[0][1] is None
