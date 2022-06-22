from test_utils import run_query, redshift_connector
import pytest


def test_quadbin_toparent():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(
            5209574053332910079,
            3) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5205105638077628415


def test_quadbin_toparent_negative_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(
                5209574053332910079,
                -1) AS OUTPUT"""
        )
    assert 'Wrong quadbin zoom' in str(excinfo.value)


def test_quadbin_toparent_resolution_overflow_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(
                5209574053332910079,
                27) AS OUTPUT"""
        )
    assert 'NULL argument passed to UDF' in str(excinfo.value)


def test_quadbin_toparent_resolution_larger_than_index_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_TOPARENT(
                5209574053332910079,
                5) AS OUTPUT"""
        )
    assert 'NULL argument passed to UDF' in str(excinfo.value)
