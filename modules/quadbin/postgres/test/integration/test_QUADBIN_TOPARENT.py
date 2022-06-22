import pytest
from test_utils import run_query

parents = [
    ( [0, 0, 0], 0, [0, 0, 0] ),
    ( [1, 0, 0], 1, [1, 0, 0] ),
    ( [1, 0, 1], 1, [1, 0, 1] ),
    ( [1, 1, 0], 1, [1, 1, 0] ),
    ( [1, 1, 1], 1, [1, 1, 1] ),
    ( [1, 0, 0], 0, [0, 0, 0] ),
    ( [1, 0, 1], 0, [0, 0, 0] ),
    ( [1, 1, 0], 0, [0, 0, 0] ),
    ( [1, 1, 1], 0, [0, 0, 0] ),
    ( [11, 400, 200], 10, [10, 200, 100] ),
    ( [11, 401, 201], 10, [10, 200, 100] ),
    ( [11, 399, 200], 10, [10, 199, 100] ),
    ( [11, 402, 200], 10, [10, 201, 100] ),
    ( [11, 400, 202], 10, [10, 200, 101] ),
    ( [14, 3200, 1600], 10, [10, 200, 100] ),
    ( [14, 3215, 1615], 10, [10, 200, 100] ),
    ( [14, 3200, 1616], 10, [10, 200, 101] ),
    ( [14, 3199, 1615], 10, [10, 199, 100] ),
    ( [14, 3199, 1616], 10, [10, 199, 101] ),
    ( [23, 8388607, 8388607], 0, [0, 0, 0] ),
    ( [23, 8388607, 8388607], 1, [1, 1, 1] )
]

@pytest.mark.parametrize('zxy, resolution, parent_zxy', parents)
def test_quadbin_toparent(zxy, resolution, parent_zxy):
    """Computes parent for quadbin"""
    z, x, y = zxy
    parent_z, parent_x, parent_y = parent_zxy
    result = run_query(f"""SELECT QUADBIN_TOZXY(QUADBIN_TOPARENT(QUADBIN_FROMZXY({z},{x},{y}),{resolution}))""")
    assert result[0][0]['z'] == parent_z
    assert result[0][0]['x'] == parent_x
    assert result[0][0]['y'] == parent_y
