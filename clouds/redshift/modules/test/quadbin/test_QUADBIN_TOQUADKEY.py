from test_utils import run_query


def test_quadbin_fromquadkey():
    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOQUADKEY(5192650370358181887)')
    assert len(result[0]) == 1
    assert result[0][0] == ''

    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOQUADKEY(5193776270265024511)')
    assert len(result[0]) == 1
    assert result[0][0] == '0'

    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOQUADKEY(5226184719091105791)')
    assert len(result[0]) == 1
    assert result[0][0] == '13020310'

    result = run_query('SELECT @@RS_SCHEMA@@.QUADBIN_TOQUADKEY(5233974874938015743)')
    assert len(result[0]) == 1
    assert result[0][0] == '0231001222'
