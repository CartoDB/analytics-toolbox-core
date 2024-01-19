import pytest
from test_utils import run_query


def test_quadbin_longlat():
    """Computes quadbin for longitude latitude."""
    result = run_query(
        """
        WITH inputs AS (
            SELECT 1 AS ID, @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4)
                UNION ALL SELECT 2,
                    @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 85.05112877980659, 26)
                UNION ALL SELECT 3, @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 88, 26)
                UNION ALL SELECT 4, @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 90, 26)
                UNION ALL SELECT 5,
                    @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -85.05112877980659, 26)
                UNION ALL SELECT 6, @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -88, 26)
                UNION ALL SELECT 7, @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -90, 26)
        )
        SELECT * FROM inputs ORDER BY id ASC"""
    )
    assert result[0][1] == 5209574053332910079
    assert result[1][1] == 5306366260949286912
    assert result[2][1] == 5306366260949286912
    assert result[3][1] == 5306366260949286912
    assert result[4][1] == 5309368660700867242
    assert result[5][1] == 5309368660700867242
    assert result[6][1] == 5309368660700867242


def test_quadbin_longlat_null_input():
    """Returns null if the input is null."""
    result = run_query(
        """
      SELECT
        @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(NULL, -3.7038, 4) AS n1,
        @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, NULL, 4) AS n2,
        @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, NULL) AS n3
    """
    )
    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None


def test_quadbin_longlat_neg_resolution():
    """Throws error for negative resolution."""
    with pytest.raises(Exception):
        run_query('SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, -1)')


def test_quadbin_longlat_large_resolution():
    """Throws error for large resolution."""
    with pytest.raises(Exception):
        run_query('SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 27)')


def test_quadbin_longlat_highest_resolution():
    query = """SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(
                    -3.71219873428345,
                    40.413365349070865,
                    26)"""
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5306319089810035706

    query = """SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(
                    40.413365349070865,
                    -3.71219873428345,
                    26)"""
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5308641755410858449

    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 3.552713678800501e-15, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5308618060762972160

    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, -3.552713678800501e-15, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5308618060762972160

    query = """SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(
                    -89.71219873428345,
                    -84.413365349070865,
                    26)"""
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5308521992464067502

    # set of call giving the same result with slightly different lat
    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.3644180297851546e-06, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5307116860887181994
    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785155e-06, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5307116860887181994
    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785156e-06, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5307116860887181994
    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785157e-06, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5307116860887181994
    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785158e-06, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5307116860887181994
    query = 'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785156e-06, 26)'
    result = run_query(query)
    assert len(result[0]) == 1
    assert result[0][0] == 5307116860887181994
