from test_utils import run_query, redshift_connector
import pytest


def test_longlat_asquadbin_success():
    results = run_query(
        """WITH zoomContext AS(
            SELECT 0 AS zoom, -150 AS long, 60 AS lat UNION ALL
            SELECT 1, -150, 60 UNION ALL
            SELECT 2, 150, 60 UNION ALL
            SELECT 3, -150, -60 UNION ALL
            SELECT 4, 150, -60 UNION ALL
            SELECT 5, -30, 30 UNION ALL
            SELECT 6, 30, 30 UNION ALL
            SELECT 7, -30, -30 UNION ALL
            SELECT 8, 30, -30 UNION ALL
            SELECT 9, -100, 0 UNION ALL
            SELECT 10, 100, 0 UNION ALL
            SELECT 11, -100, 0 UNION ALL
            SELECT 12, 100, 0 UNION ALL
            SELECT 13, 0, 45 UNION ALL
            SELECT 14, 0, 45 UNION ALL
            SELECT 15, 0, -45 UNION ALL
            SELECT 16, 0, -45 UNION ALL
            SELECT 17, -70, 10 UNION ALL
            SELECT 18, 70, 10 UNION ALL
            SELECT 19, -70, -10 UNION ALL
            SELECT 20, 70, -10 UNION ALL
            SELECT 21, -10, 80 UNION ALL
            SELECT 22, 10, 80 UNION ALL
            SELECT 23, -10, -80 UNION ALL
            SELECT 24, 10, -80 UNION ALL
            SELECT 25, -45, 25 UNION ALL
            SELECT 26, 45, 25 UNION ALL
            SELECT 27, -45, -25 UNION ALL
            SELECT 28, 45, -25 UNION ALL
            SELECT 29, 0, 0
        )
        SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(long, lat, zoom) as quadbins
            FROM zoomContext;"""
    )

    fixture_file = open(
        './test/integration/longlat_asquadbin_fixtures/out/quadbins.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_longlat_asquadbin_wrong_zoom_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(100, 100, 30)')
    assert 'Wrong zoom' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(100, 100, -1)')
    assert 'Wrong zoom' in str(excinfo.value)


def test_longlat_asquadbin_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(NULL, 10, 10)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(10, NULL, 10)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT(10, 10, NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
