import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_s2_boundary_success():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.S2_BOUNDARY(955484400630366208) as geog1,
        @@RS_SCHEMA@@.S2_BOUNDARY(936748722493063168) as geog2,
        @@RS_SCHEMA@@.S2_BOUNDARY(5731435257080539263) as geog3"""
    )

    with open(f'{here}/fixtures/s2_boundary_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_s2_boundary_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_BOUNDARY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
