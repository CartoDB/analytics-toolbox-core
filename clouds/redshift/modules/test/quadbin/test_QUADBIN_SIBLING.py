import pytest

from test_utils import run_query, ProgrammingError


def test_quadbin_sibling_up():
    result = run_query(
        "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'up')"
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5208061125333090303


def test_quadbin_sibling_down():
    result = run_query(
        "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'down')"
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209609237704998911


def test_quadbin_sibling_left():
    result = run_query(
        "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'left')"
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209556461146865663


def test_quadbin_sibling_right():
    result = run_query(
        "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'right')"
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209626829891043327


def test_quadbin_sibling_none():
    result = run_query(
        "SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5192650370358181887, 'up')"
    )

    assert len(result[0]) == 1
    assert result[0][0] is None


def test_quadbin_sibling_failure():
    error = 'Wrong direction argument passed to sibling'
    with pytest.raises(ProgrammingError, match=error):
        run_query("SELECT @@RS_SCHEMA@@.QUADBIN_SIBLING(5209574053332910079, 'wrong')")
