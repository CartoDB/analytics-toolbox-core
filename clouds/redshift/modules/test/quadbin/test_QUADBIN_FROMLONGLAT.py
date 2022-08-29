import pytest

from test_utils import run_query, ProgrammingError


def test_quadbin_fromlonglat():
    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4)')

    assert len(result[0]) == 1
    assert result[0][0] == 5209574053332910079


def test_quadbin_fromlonglat_null():
    result = run_query(
        """
        SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(NULL, -3.7038, 4),
               @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, NULL, 4),
               @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, NULL)
    """
    )

    assert len(result[0]) == 3
    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None


def test_quadbin_negative_resolution_failure():
    error = 'Invalid resolution: should be between 0 and 26'
    with pytest.raises(ProgrammingError, match=error):
        run_query('SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, -1)')


def test_quadbin_fromlonglat_resolution_overflow_failure():
    error = 'Invalid resolution: should be between 0 and 26'
    with pytest.raises(ProgrammingError, match=error):
        run_query('SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 27)')
