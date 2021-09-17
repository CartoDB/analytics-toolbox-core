from test_utils import run_query, redshift_connector
import pytest


def test_tochildren_success():
    results = run_query(
        """WITH context AS(
            SELECT
            -7843177080740118528 AS id,
            *
            FROM generate_series(8, 12) resolution
        )
        SELECT @@RS_PREFIX@@s2.TOCHILDREN(id, resolution) AS children_ids
        FROM context;"""
    )

    fixture_file = open(
        './test/integration/tochildren_fixtures/out/children_ids.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert result[0] == lines[idx].rstrip()


def test_tochildren_invalid_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.TOCHILDREN(4611686027017322525, 31)')
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.TOCHILDREN(-7843177080740118528, 5)')
    assert 'InvalidResolution' in str(excinfo.value)


# def test_tochildren_null_failure():
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.TOCHILDREN(NULL, 1)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
#     with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
#         run_query('SELECT @@RS_PREFIX@@quadkey.TOCHILDREN(322, NULL)')
#     assert 'NULL argument passed to UDF' in str(excinfo.value)
