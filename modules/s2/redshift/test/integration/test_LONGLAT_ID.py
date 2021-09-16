from test_utils import run_query, redshift_connector
import pytest


def test_longlat_id_success():
    results = run_query(
        """WITH resContext AS(
            SELECT 0 AS res, -150 AS long, 60 AS lat UNION ALL
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
            SELECT 29, 0, 0 UNION ALL
            SELECT 30, -3, 40
        )
        SELECT @@RS_PREFIX@@s2.LONGLAT_ASID(long, lat, res) as ids
            FROM resContext;"""
    )

    fixture_file = open(
        './test/integration/longlat_asid_fixtures/out/int64_ids.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_longlat_asid_invalid_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.LONGLAT_ASID(100, 100, 32)')
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.LONGLAT_ASID(100, 100, -1)')
    assert 'InvalidResolution' in str(excinfo.value)


# def test_longlat_asquadint_null_failure():
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASID(NULL, 10, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASID(10, NULL, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.LONGLAT_ASID(10, 10, NULL)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
