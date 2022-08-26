import pytest
from test_utils import run_query


def test_quadbin_longlat():
    """Computes quadbin for longitude latitude."""
    result = run_query('SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4)')
    assert result[0][0] == 5209574053332910079


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
