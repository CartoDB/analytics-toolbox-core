from test_utils import run_query, redshift_connector
import pytest


def test_bbox_success():
    result = run_query(
        """SELECT @@RS_PREFIX@@quadkey.QUADINT_BBOX(162) as bbox1,
        @@RS_PREFIX@@quadkey.QUADINT_BBOX(12070922) as bbox2,
        @@RS_PREFIX@@quadkey.QUADINT_BBOX(791040491538) as bbox3,
        @@RS_PREFIX@@quadkey.QUADINT_BBOX(12960460429066265) as bbox4"""
    )

    assert result[0][0] == '[-90.0,0.0,0.0,66.51326044311186]'
    assert result[0][1] == '[-45.0,44.84029065139799,-44.6484375,45.089035564831015]'
    assert (
        result[0][2]
        == '[-45.0,44.99976701918129,-44.998626708984375,45.000738078290674]'
    )
    assert (
        result[0][3] == '[-45.0,44.99999461263668,-44.99998927116394,45.00000219906962]'
    )


def test_bbox_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@quadkey.QUADINT_BBOX(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
