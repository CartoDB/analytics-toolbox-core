import json
import pytest

from test_utils import run_query, ProgrammingError


def test_quadbin_tochildren():
    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079,5)')

    assert len(result[0]) == 1
    assert (
        json.loads(result[0][0]).sort()
        == [
            5214064458820747263,
            5214073254913769471,
            5214068856867258367,
            5214077652960280575,
        ].sort()
    )


def test_quadbin_tochildren_negative_resolution_failure():
    error = 'Invalid resolution'
    with pytest.raises(ProgrammingError, match=error):
        run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, -1)')


def test_quadbin_tochildren_resolution_overflow_failure():
    error = 'Invalid resolution'
    with pytest.raises(ProgrammingError, match=error):
        run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, 27)')


def test_quadbin_tochildren_resolution_smaller_than_index_failure():
    error = 'Invalid resolution'
    with pytest.raises(ProgrammingError, match=error):
        run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079,3)')
