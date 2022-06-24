from test_utils import run_query, redshift_connector
import pytest


def test_quadbin_fromlonglat():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(
            40.4168, -3.7038
            ,
            4) AS output"""
    )

    assert len(result[0]) == 1
    assert result[0][0] == 5209574053332910079


def test_quadbin_fromlonglat_null():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(NULL, -3.7038, 4) AS output0,
            @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(40.4168, NULL, 4) AS output1,
            @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(40.4168, -3.7038, NULL) AS output2"""
    )
    assert len(result[0]) == 3
    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None


def test_quadbin_negative_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(
                40.4168,
                -3.7038,
                -1) AS OUTPUT"""
        )
    assert 'Invalid resolution; should be between 0 and 26' in str(excinfo.value)


def test_quadbin_fromlonglat_resolution_overflow_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(
                40.4168,
                -3.7038,
                27) AS OUTPUT"""
        )
    assert 'Invalid resolution; should be between 0 and 26' in str(excinfo.value)
