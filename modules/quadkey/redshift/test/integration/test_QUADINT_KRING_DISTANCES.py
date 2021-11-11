import pytest
from test_utils import run_query, redshift_connector


def test_kring_distances_success():
    result = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADINT_KRING_DISTANCES(162, 1),
            @@RS_PREFIX@@carto.QUADINT_KRING_DISTANCES(12070922, 1),
            @@RS_PREFIX@@carto.QUADINT_KRING_DISTANCES(12070922, 2)"""
    )

    assert result[0][0] == (
        '[{"index":2,"distance":0},{"index":34,"distance":1},'
        '{"index":66,"distance":2},{"index":130,"distance":1},'
        '{"index":162,"distance":1},{"index":194,"distance":2},'
        '{"index":258,"distance":2},{"index":290,"distance":2},'
        '{"index":322,"distance":2}]'
    )
    assert result[0][1] == (
        '[{"index":12038122,"distance":0},{"index":12038154,"distance":1},'
        '{"index":12038186,"distance":2},{"index":12070890,"distance":1},'
        '{"index":12070922,"distance":1},{"index":12070954,"distance":2},'
        '{"index":12103658,"distance":2},{"index":12103690,"distance":2},'
        '{"index":12103722,"distance":2}]'
    )
    assert result[0][2] == (
        '[{"index":12005322,"distance":0},{"index":12005354,"distance":1},'
        '{"index":12005386,"distance":2},{"index":12005418,"distance":3},'
        '{"index":12005450,"distance":4},{"index":12038090,"distance":1},'
        '{"index":12038122,"distance":1},{"index":12038154,"distance":2},'
        '{"index":12038186,"distance":3},{"index":12038218,"distance":4},'
        '{"index":12070858,"distance":2},{"index":12070890,"distance":2},'
        '{"index":12070922,"distance":2},{"index":12070954,"distance":3},'
        '{"index":12070986,"distance":4},{"index":12103626,"distance":3},'
        '{"index":12103658,"distance":3},{"index":12103690,"distance":3},'
        '{"index":12103722,"distance":3},{"index":12103754,"distance":4},'
        '{"index":12136394,"distance":4},{"index":12136426,"distance":4},'
        '{"index":12136458,"distance":4},{"index":12136490,"distance":4},'
        '{"index":12136522,"distance":4}]'
    )


def test_kring_distances_invalid_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_KRING_DISTANCES(NULL, NULL)')
    assert 'Invalid input origin' in str(excinfo.value)

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_KRING_DISTANCES(-1, 1)')
    assert 'Invalid input origin' in str(excinfo.value)

    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADINT_KRING_DISTANCES(162, -1)')
    assert 'Invalid input size' in str(excinfo.value)
