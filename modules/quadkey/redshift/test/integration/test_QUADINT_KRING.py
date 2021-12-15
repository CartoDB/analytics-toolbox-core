import pytest
from test_utils import run_query, redshift_connector


def test_kring_success():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADINT_KRING(162, 1),
            @@RS_PREFIX@@carto.QUADINT_KRING(12070922, 1),
            @@RS_PREFIX@@carto.QUADINT_KRING(12070922, 2)"""
    )

    assert result[0][0] == '[2,34,66,130,162,194,258,290,322]'
    assert result[0][1] == (
        '[12038122,12038154,12038186,12070890,12070922,12070954,'
        '12103658,12103690,12103722]'
    )
    assert result[0][2] == (
        '[12005322,12005354,12005386,12005418,12005450,12038090,12038122,12038154,'
        '12038186,12038218,12070858,12070890,12070922,12070954,12070986,12103626,'
        '12103658,12103690,12103722,12103754,12136394,12136426,12136458,12136490,'
        '12136522]'
    )


def test_kring_invalid_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_KRING(NULL, NULL)')
    assert 'Invalid input origin' in str(excinfo.value)

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_KRING(-1, 1)')
    assert 'Invalid input origin' in str(excinfo.value)

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_KRING(162, -1)')
    assert 'Invalid input size' in str(excinfo.value)
