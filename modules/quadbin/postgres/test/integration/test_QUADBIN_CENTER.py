import pytest
from test_utils import run_query

def test_quadbin_center():
    """Computes center for quadbin"""
    result = run_query(f"""SELECT ST_ASTEXT(QUADBIN_CENTER(5209574053332910079))""")
    assert result[0][0] == 'POINT(33.75 -11.178401873711776)'
