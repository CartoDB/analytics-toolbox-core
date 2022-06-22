import pytest
from test_utils import run_query

def test_quadbin_isvalid():
    """Detects valid quadbins"""
    result = run_query(f"""SELECT QUADBIN_ISVALID(5209574053332910079)""")
    assert result[0][0] == True

def test_quadbin_isvalid_invalid():
    """Detects invalid quadbins"""
    result = run_query(f"""SELECT QUADBIN_ISVALID(1234)""")
    assert result[0][0] == False

def test_quadbin_isvalid_invalid_trailingbits():
    """Detects invalid trailing bits"""
    result = run_query(f"""SELECT QUADBIN_ISVALID(5209538868960821248)""")
    assert result[0][0] == False
