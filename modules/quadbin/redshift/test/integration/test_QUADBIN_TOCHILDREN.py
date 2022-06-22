from test_utils import run_query, redshift_connector
import pytest
import json


def test_quadbin_tochildren():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(
            5209574053332910079,
            5) AS output"""
    )

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
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(
                5209574053332910079,
                -1) AS OUTPUT"""
        )
    assert 'Wrong quadbin zoom' in str(excinfo.value)


def test_quadbin_tochildren_resolution_overflow_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(
                5209574053332910079,
                27) AS OUTPUT"""
        )
    assert 'NULL argument passed to UDF' in str(excinfo.value)


def test_quadbin_tochildren_resolution_smaller_than_index_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            """SELECT @@RS_PREFIX@@carto.QUADBIN_TOCHILDREN(
                5209574053332910079,
                3) AS OUTPUT"""
        )
    assert 'Wrong quadbin zoom' in str(excinfo.value)
