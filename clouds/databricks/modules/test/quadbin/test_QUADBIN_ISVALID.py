# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_isvalid():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_ISVALID(5209574053332910079)')

    assert result[0][0] is True


def test_quadbin_isvalid_invalid_index():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_ISVALID(1234)')

    assert result[0][0] is False


def test_quadbin_isvalid_invalid_trailing_bits():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_ISVALID(5209538868960821248)')

    assert result[0][0] is False


def test_quadbin_isvalid_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_ISVALID(NULL)')

    assert result[0][0] is False
