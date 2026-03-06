# Copyright (c) 2026, CARTO

import pytest

from test_utils import run_query


QUADBIN_QUADKEY_PAIRS = [
    (5192650370358181887, ''),
    (5193776270265024511, '0'),
    (5226184719091105791, '13020310'),
    (5233974874938015743, '0231001222'),
]


@pytest.mark.parametrize('quadbin, expected_quadkey', QUADBIN_QUADKEY_PAIRS)
def test_quadbin_toquadkey(quadbin, expected_quadkey):
    result = run_query(f'SELECT @@DB_SCHEMA@@.QUADBIN_TOQUADKEY({quadbin})')

    assert result[0][0] == expected_quadkey


def test_quadbin_toquadkey_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_TOQUADKEY(NULL)')

    assert result[0][0] is None
