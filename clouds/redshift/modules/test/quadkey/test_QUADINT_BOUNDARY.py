import os
import pytest

from test_utils import run_query, ProgrammingError

here = os.path.dirname(__file__)


def test_boundary_success():
    results = run_query(
        """SELECT @@RS_SCHEMA@@.QUADINT_BOUNDARY(12070922) as geog1,
        @@RS_SCHEMA@@.QUADINT_BOUNDARY(791040491538) as geog2,
        @@RS_SCHEMA@@.QUADINT_BOUNDARY(12960460429066265) as geog3"""
    )

    with open(f'{here}/fixtures/quadint_boundary_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_boundary_null_failure():
    with pytest.raises(ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.QUADINT_BOUNDARY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
