from test_utils import run_query, redshift_connector
import pytest


def test_toparent_success():
    results = run_query(
        """WITH context AS(
            SELECT
            -7843177080740118528 AS id,
            *
            FROM generate_series(0, 8) resolution
        )
        SELECT @@RS_PREFIX@@s2.TOPARENT(id, resolution) AS parent_id
        FROM context;"""
    )

    fixture_file = open('./test/integration/toparent_fixtures/out/parent_ids.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_toparent_invalid_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.TOPARENT(0, -1)')
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.TOPARENT(-7843177080740118528, 9)')
    assert 'InvalidResolution' in str(excinfo.value)


# def test_toparent_null_failure():
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.TOPARENT(NULL, 10)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.TOPARENT(322, NULL)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
