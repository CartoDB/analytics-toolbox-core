import pytest
from test_utils import run_query

input = [
    # quadkey, quadbin
    ('', 5192650370358181887),
    ('0', 5193776270265024511),
    ('13020310', 5226184719091105791),
    ('0231001222', 5233974874938015743),
]


@pytest.mark.parametrize('quadkey, quadbin', input)
def test_quadbin_fromquadkey(quadkey, quadbin):
    result = run_query(f"SELECT @@RS_SCHEMA@@.QUADBIN_FROMQUADKEY('{quadkey}')")
    assert len(result[0]) == 1
    assert result[0][0] == quadbin
