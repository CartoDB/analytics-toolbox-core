import pytest
from test_utils import run_query

def test_quadbin_sibling_up():
    """Computes top sibling"""
    result = run_query(f"""SELECT QUADBIN_SIBLING(5209574053332910079, 'up')""")
    assert result[0][0] == 5208061125333090303

def test_quadbin_sibling_down():
    """Computes bottom sibling"""
    result = run_query(f"""SELECT QUADBIN_SIBLING(5209574053332910079, 'down')""")
    assert result[0][0] == 5209609237704998911

def test_quadbin_sibling_left():
    """Computes left sibling"""
    result = run_query(f"""SELECT QUADBIN_SIBLING(5209574053332910079, 'left')""")
    assert result[0][0] == 5209556461146865663

def test_quadbin_sibling_right():
    """Computes left sibling"""
    result = run_query(f"""SELECT QUADBIN_SIBLING(5209574053332910079, 'right')""")
    assert result[0][0] == 5209626829891043327

def test_quadbin_sibling_null():
    """Returns NULL if the sibling does not exist"""
    result = run_query(f"""SELECT QUADBIN_SIBLING(5192650370358181887, 'up')""")
    assert result[0][0] == None
