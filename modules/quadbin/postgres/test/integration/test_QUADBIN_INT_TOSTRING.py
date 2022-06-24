import pytest
from test_utils import run_query

def test_quadbin_int_tostring():
    """Computes string quadbin"""
    result = run_query(f"""SELECT __QUADBIN_INT_TOSTRING(5209574053332910079)""")
    assert result[0][0] == '484c1fffffffffff'
