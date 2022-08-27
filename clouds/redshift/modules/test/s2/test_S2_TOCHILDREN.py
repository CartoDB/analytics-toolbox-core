import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_s2_tochildren_success():
    results = run_query(
        """WITH context AS(
            SELECT
            -7843177080740118528 AS id,
            *
            FROM generate_series(8, 12) resolution
        )
        SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(id, resolution) AS children_ids
        FROM context;"""
    )

    with open(f'{here}/fixtures/s2_tochildren_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_tochildren_invalid_resolution_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(4611686027017322525, 31)')
    assert 'InvalidResolution' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(-7843177080740118528, 5)')
    assert 'InvalidResolution' in str(excinfo.value)


def test_s2_tochildren_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(NULL, 1)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(-7843177080740118528, NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
