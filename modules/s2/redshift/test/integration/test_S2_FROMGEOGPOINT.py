from test_utils import run_query, redshift_connector
import pytest


def test_longlat_asid_success():
    results = run_query(
        """WITH resContext AS(
            SELECT 0 AS res, ST_POINT(-150, 60) AS point UNION ALL
            SELECT 1, ST_POINT(-150, 60) UNION ALL
            SELECT 2, ST_POINT(150, 60) UNION ALL
            SELECT 3, ST_POINT(-150, -60) UNION ALL
            SELECT 4, ST_POINT(150, -60) UNION ALL
            SELECT 5, ST_POINT(-30, 30) UNION ALL
            SELECT 6, ST_POINT(30, 30) UNION ALL
            SELECT 7, ST_POINT(-30, -30) UNION ALL
            SELECT 8, ST_POINT(30, -30) UNION ALL
            SELECT 9, ST_POINT(-100, 0) UNION ALL
            SELECT 10, ST_POINT(100, 0) UNION ALL
            SELECT 11, ST_POINT(-100, 0) UNION ALL
            SELECT 12, ST_POINT(100, 0) UNION ALL
            SELECT 13, ST_POINT(0, 45) UNION ALL
            SELECT 14, ST_POINT(0, 45) UNION ALL
            SELECT 15, ST_POINT(0, -45) UNION ALL
            SELECT 16, ST_POINT(0, -45) UNION ALL
            SELECT 17, ST_POINT(-70, 10) UNION ALL
            SELECT 18, ST_POINT(70, 10) UNION ALL
            SELECT 19, ST_POINT(-70, -10) UNION ALL
            SELECT 20, ST_POINT(70, -10) UNION ALL
            SELECT 21, ST_POINT(-10, 80) UNION ALL
            SELECT 22, ST_POINT(10, 80) UNION ALL
            SELECT 23, ST_POINT(-10, -80) UNION ALL
            SELECT 24, ST_POINT(10, -80) UNION ALL
            SELECT 25, ST_POINT(-45, 25) UNION ALL
            SELECT 26, ST_POINT(45, 25) UNION ALL
            SELECT 27, ST_POINT(-45, -25) UNION ALL
            SELECT 28, ST_POINT(45, -25) UNION ALL
            SELECT 29, ST_POINT(0, 0) UNION ALL
            SELECT 30, ST_POINT(-3, 40)
        )
        SELECT @@RS_PREFIX@@carto.S2_FROMGEOGPOINT(point, res) as ids
            FROM resContext;"""
    )

    fixture_file = open('./test/integration/longlat_asid_fixtures/out/ids.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_longlat_asid_invalid_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            'SELECT @@RS_PREFIX@@carto.S2_FROMGEOGPOINT(ST_POINT(100, 100), 32)'
        )
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query(
            'SELECT @@RS_PREFIX@@carto.S2_FROMGEOGPOINT(ST_POINT(100, 100), -1)'
        )
    assert 'InvalidResolution' in str(excinfo.value)


# def test_longlat_asquadint_null_failure():
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@carto.S2_FROMLONGLAT(NULL, 10, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@carto.S2_FROMLONGLAT(10, NULL, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@carto.S2_FROMLONGLAT(10, 10, NULL)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
