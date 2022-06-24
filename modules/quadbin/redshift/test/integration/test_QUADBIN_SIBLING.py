from test_utils import run_query, redshift_connector
import pytest


def test_quadbin_sibling_up():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_SIBLING(
                5209574053332910079,
                'up') AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5208061125333090303


def test_quadbin_sibling_down():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_SIBLING(
                5209574053332910079,
                'down') AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209609237704998911


def test_quadbin_sibling_left():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_SIBLING(
                5209574053332910079,
                'left') AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209556461146865663


def test_quadbin_sibling_right():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_SIBLING(
                5209574053332910079,
                'right') AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209626829891043327


def test_quadbin_sibling_none():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_SIBLING(
                5192650370358181887,
                'up') AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] is None


def test_quadbin_sibling_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_SIBLING(
                5209574053332910079,
                'wrong') AS OUTPUT"""
        )
    assert 'Wrong direction argument passed to sibling' in str(excinfo.value)
