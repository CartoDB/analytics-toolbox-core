import pytest
from test_utils import run_query
import json

quadbins = [
    # z, x, y, quadbin
    ( 0, 0, 0, 5192650370358181887 ),
    ( 1, 0, 0, 5193776270265024511 ),
    ( 1, 0, 1, 5196028070078709759 ),
    ( 1, 1, 0, 5194902170171867135 ),
    ( 1, 1, 1, 5197153969985552383 )
]

@pytest.mark.parametrize('z, x, y, quadbin', quadbins)
def test_quadbin_fromzxy(z, x, y, quadbin):
    """Computes quadbin for z, x, y"""
    result = run_query(f"""SELECT QUADBIN_FROMZXY({z},{x},{y})""")
    assert result[0][0] == quadbin
