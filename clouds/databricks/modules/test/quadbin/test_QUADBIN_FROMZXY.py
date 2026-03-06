# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromzxy():
    result = run_query("SELECT @@DB_SCHEMA@@.QUADBIN_FROMZXY(4, 9, 8)")

    assert result[0][0] == 5209574053332910079


def test_quadbin_fromzxy_null():
    result = run_query(
        "SELECT"
        "    @@DB_SCHEMA@@.QUADBIN_FROMZXY(NULL, 9, 8),"
        "    @@DB_SCHEMA@@.QUADBIN_FROMZXY(4, NULL, 8),"
        "    @@DB_SCHEMA@@.QUADBIN_FROMZXY(4, 9, NULL)"
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None
