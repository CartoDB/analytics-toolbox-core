import pytest
from test_utils import run_query
import json

def test_quadbin_fromzxy():
    """Computes quadbin for root tile"""
    result = run_query("""SELECT QUADBIN_FROMZXY(0,0,0)""")
    assert result[0][0] == 5192650370358181887
