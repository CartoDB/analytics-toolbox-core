import os
import pytest

from test_utils import run_query, ProgrammingError

here = os.path.dirname(__file__)


def test_st_tileenvelope_success():
    results = run_query(
        """
        WITH __input AS (
            SELECT 10 z, 384 x, 368 y UNION ALL
            SELECT 18, 98304, 94299 UNION ALL
            SELECT 25, 12582912, 12070369
        )
        SELECT ST_ASTEXT(@@RS_SCHEMA@@.ST_TILEENVELOPE(z, x, y))
        FROM __input
    """
    )

    with open(f'{here}/fixtures/st_tileenvelope_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_st_tileenvelope_null():
    error = 'NULL argument passed to UDF'
    with pytest.raises(ProgrammingError, match=error):
        run_query('SELECT @@RS_SCHEMA@@.ST_TILEENVELOPE(10, 384, NULL)')
