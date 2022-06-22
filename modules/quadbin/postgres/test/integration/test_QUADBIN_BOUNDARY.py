import pytest
from test_utils import run_query

def test_quadbin_boundary():
    """Computes boundary for quadbin"""
    result = run_query(f"""SELECT ST_ASTEXT(QUADBIN_BOUNDARY(5209574053332910079))""")
    assert result[0][0] == 'POLYGON((22.5 -21.943045533438166,22.5 0,45 0,45 -21.943045533438166,22.5 -21.943045533438166))'
