# Copyright (c) 2026, CARTO

import pytest

from test_utils import run_query


QUADKEY_QUADBIN_PAIRS = [
    ("", 5192650370358181887),
    ("0", 5193776270265024511),
    ("13020310", 5226184719091105791),
    ("0231001222", 5233974874938015743),
]


@pytest.mark.parametrize("quadkey, expected_quadbin", QUADKEY_QUADBIN_PAIRS)
def test_quadbin_fromquadkey(quadkey, expected_quadbin):
    result = run_query(f"SELECT @@DB_SCHEMA@@.QUADBIN_FROMQUADKEY('{quadkey}')")

    assert result[0][0] == expected_quadbin


def test_quadbin_fromquadkey_null():
    result = run_query("SELECT @@DB_SCHEMA@@.QUADBIN_FROMQUADKEY(NULL)")

    assert result[0][0] is None
